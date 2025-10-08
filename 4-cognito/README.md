# 🔐 Cognito & Lambda Auth - Camada 5

## 📋 Visão Geral

Esta camada implementa o sistema de autenticação usando AWS Cognito e Lambda para a aplicação Fast Food. Ela provê:

- **Cognito User Pool**: Gerencia autenticação de usuários e geração de tokens JWT
- **Lambda Auth (Função)**: Função de duplo propósito para autenticação e autorização
- **S3 Bucket**: Armazena os pacotes de deployment da Lambda
- **IAM Roles & Policies**: Controle de acesso seguro

## 🏗️ Arquitetura

```
┌─────────────┐
│   Cliente   │
└──────┬──────┘
       │ POST /auth {cpf}
       ▼
┌─────────────────┐
│  API Gateway    │
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│  Lambda Auth         │
│  (Duplo Propósito)   │
│                      │
│  1. Autenticação     │
│  2. Autorização      │
└─────┬────────────┬───┘
      │            │
      ▼            ▼
┌──────────┐  ┌─────────────┐
│   RDS    │  │   Cognito   │
│  MySQL   │  │  User Pool  │
└──────────┘  └─────────────┘
```

## 📦 Recursos Criados

### Cognito
- **User Pool**: `soat-fast-food-users-dev`
- **App Client**: `soat-fast-food-lambda-client-dev`
- **Atributos Customizados**: `customer_id`, `cpf`
- **Domínio**: `soat-fast-food-dev`

### Lambda
- **Função**: `soat-fast-food-auth-dev`
- **Runtime**: Node.js 20.x
- **Memória**: 512 MB
- **Timeout**: 30 segundos
- **VPC**: Habilitado (subnets privadas)

### S3
- **Bucket**: `soat-fast-food-lambda-packages-dev`
- **Versionamento**: Habilitado
- **Criptografia**: AES256

### Segurança
- **Security Group da Lambda**: Acesso ao RDS e Cognito
- **IAM Role**: Execução da Lambda com permissões para Cognito e RDS
- **CloudWatch Logs**: `/aws/lambda/soat-fast-food-auth-dev`

## 🚀 Deployment

### Pré-requisitos

1. **Camadas anteriores aplicadas**:
   - 0-bootstrap (S3 backend)
   - 1-networking (VPC, subnets)
   - Camada de banco (RDS MySQL)

2. **Código da Lambda enviado ao S3**:
   ```bash
   # Upload do pacote da Lambda (via CI/CD)
   aws s3 cp lambda.zip s3://soat-fast-food-lambda-packages-dev/auth/lambda.zip
   ```

### Passos de Deploy

```bash
# 1. Vá para a pasta da camada
cd soat_tech_challenge_fast_food_infra/4-cognito

# 2. Inicialize o Terraform
terraform init

# 3. Planeje a mudança
terraform plan -var="db_password=SUA_SENHA_DO_DB"

# 4. Aplique as mudanças
terraform apply -var="db_password=SUA_SENHA_DO_DB"
```

### Usando arquivo tfvars (recomendado)

```bash
# Crie o terraform.tfvars
cat > terraform.tfvars <<EOF
aws_region   = "us-east-1"
project_name = "soat-fast-food"
environment  = "dev"
db_password  = "SUA_SENHA_SEGURA"
EOF

# Deploy
terraform apply
```

## 🔧 Configuração

### Variáveis

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `aws_region` | string | `us-east-1` | Região AWS |
| `aws_profile` | string | `default` | Perfil do AWS CLI |
| `project_name` | string | `soat-fast-food` | Nome do projeto |
| `environment` | string | `dev` | Ambiente |
| `db_password` | string | - | Senha do RDS (obrigatória) |
| `lambda_runtime` | string | `nodejs20.x` | Runtime da Lambda |
| `lambda_timeout` | number | `30` | Timeout da Lambda (segundos) |
| `lambda_memory_size` | number | `512` | Memória da Lambda (MB) |

### Outputs

| Output | Descrição |
|--------|-----------|
| `cognito_user_pool_id` | ID do Cognito User Pool |
| `cognito_client_id` | ID do Cognito App Client |
| `lambda_auth_invoke_arn` | ARN de invocação da Lambda |
| `lambda_packages_bucket_name` | Nome do bucket S3 |

## 🔐 Fluxo de Autenticação

### 1. Autenticação de Usuário (POST /auth)

```javascript
// Requisição
POST /auth
{
  "cpf": "12345678900"
}

// Resposta de Sucesso (200)
{
  "token": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "id": 1,
    "cpf": "12345678900",
    "email": "user@example.com",
    "name": "John Doe"
  }
}

// Resposta de Erro (404)
{
  "error": "Customer not found",
  "message": "Cliente não encontrado. Cadastre-se primeiro."
}
```

### 2. Autorização de Requisição

```javascript
// Requisição com JWT
GET /orders
Headers: {
  "Authorization": "Bearer eyJhbGc..."
}

// Lambda valida o JWT e retorna a policy
{
  "principalId": "user-sub",
  "policyDocument": {
    "Statement": [{
      "Action": "execute-api:Invoke",
      "Effect": "Allow",
      "Resource": "arn:aws:execute-api:..."
    }]
  },
  "context": {
    "customerId": "1",
    "cpf": "12345678900",
    "email": "user@example.com"
  }
}
```

## 🧪 Testes

### Testar Autenticação

```bash
# Obter detalhes do Cognito
POOL_ID=$(terraform output -raw cognito_user_pool_id)
CLIENT_ID=$(terraform output -raw cognito_client_id)

# Testar Lambda localmente (se o código estiver pronto)
aws lambda invoke \
  --function-name soat-fast-food-auth-dev \
  --payload '{"body":"{\"cpf\":\"12345678900\"}"}' \
  response.json

cat response.json
```

### Testar via API Gateway

```bash
# Após integrar com o API Gateway
curl -X POST https://sua-url-do-api-gateway/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678900"}'
```

## 📊 Monitoramento

### CloudWatch Logs

```bash
# Ver logs da Lambda
aws logs tail /aws/lambda/soat-fast-food-auth-dev --follow

# Filtrar erros
aws logs filter-log-events \
  --log-group-name /aws/lambda/soat-fast-food-auth-dev \
  --filter-pattern "ERROR"
```

### Métricas

- **Invocations**: Número de execuções da Lambda
- **Duration**: Tempo de execução
- **Errors**: Invocações com falha
- **Throttles**: Ocorrências de rate limit

## 🔄 Atualizações

### Atualizar Código da Lambda

```bash
# Via CI/CD (automático)
git push origin main

# Atualização manual
aws lambda update-function-code \
  --function-name soat-fast-food-auth-dev \
  --s3-bucket soat-fast-food-lambda-packages-dev \
  --s3-key auth/lambda.zip
```

### Atualizar Infraestrutura

```bash
# Altere os arquivos .tf
terraform plan
terraform apply
```

## 🚨 Troubleshooting

### Lambda não conecta no RDS

**Problema**: Timeout ou conexão recusada

**Solução**:
1. Verifique regras dos security groups
2. Confirme se a Lambda está nas subnets corretas
3. Garanta que o SG do RDS permite o SG da Lambda

```bash
# Ver configuração de VPC da Lambda
aws lambda get-function-configuration \
  --function-name soat-fast-food-auth-dev \
  --query 'VpcConfig'
```

### Erros no Cognito

**Problema**: Criação de usuário falha

**Solução**:
1. Verifique permissões de IAM
2. Valide a configuração do User Pool
3. Cheque atributos customizados

```bash
# Testar acesso ao Cognito
aws cognito-idp list-users \
  --user-pool-id $POOL_ID
```

### Validação de JWT falha

**Problema**: Authorizer nega tokens válidos

**Solução**:
1. Verifique se o token não expirou
2. Confira o User Pool ID e Client ID
3. Garanta que o token é do pool correto

## 🗑️ Limpeza

```bash
# Destruir todos os recursos
terraform destroy -var="db_password=SUA_SENHA_DO_DB"

# Observação: O bucket S3 deve estar vazio antes
aws s3 rm s3://soat-fast-food-lambda-packages-dev --recursive
```

## 📚 Referências

- [AWS Cognito User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [Lambda Authorizers](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-lambda-authorizer.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🔗 Dependências

### Upstream (Obrigatórias)
- `0-bootstrap`: S3 backend
- `1-networking`: VPC, subnets
- `db`: RDS MySQL

### Downstream (Consome esta camada)
- `5-api-gateway`: Integração com API Gateway

---

**Última atualização**: 2025-01-07  
**Versão**: 1.0.0

