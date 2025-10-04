# 4-API-Gateway - Amazon API Gateway

## 📋 Descrição

Esta camada cria o Amazon API Gateway HTTP API para expor os serviços do backend. Inclui configuração de CORS, logging e preparação para VPC Link.

## 🎯 Recursos Criados

### API Gateway HTTP API
- **Nome**: soat-fast-food-api
- **Tipo**: HTTP API
- **CORS**: Configurado para permitir origens, métodos e headers específicos
- **Stage**: dev (auto-deploy habilitado)

### CloudWatch Logs
- **Log Group**: /aws/apigateway/soat-fast-food-api
- **Retention**: 7 dias
- **Format**: JSON estruturado com detalhes da requisição

### Recursos Preparados (Comentados)
- **Security Group**: Para VPC Link
- **VPC Link**: Para conectar com serviços na VPC privada
- **Integrations**: Templates para integração com backend
- **Routes**: Templates para rotas da API

## ⚙️ Configuração

### Backend

Esta camada usa S3 como backend remoto:
- **Bucket**: soat-fast-food-terraform-states
- **Key**: 4-api-gateway/terraform.tfstate
- **Region**: us-east-1
- **Encryption**: Habilitada

### Dependências

Esta camada depende da camada **1-networking** via `terraform_remote_state`:
- Busca VPC ID e subnet IDs (para VPC Link futuro)
- Preparado para integração com recursos de rede

### Variáveis

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `aws_profile` | Perfil AWS CLI | `elvismariel` |
| `project_name` | Nome do projeto | `soat-fast-food` |
| `environment` | Ambiente | `dev` |
| `api_name` | Nome do API Gateway | `soat-fast-food-api` |
| `stage_name` | Nome do stage | `dev` |
| `auto_deploy` | Auto-deploy habilitado | `true` |
| `log_retention_days` | Retenção de logs (dias) | `7` |
| `cors_allow_origins` | Origens permitidas CORS | `["*"]` |
| `cors_allow_methods` | Métodos permitidos CORS | `["GET", "POST", "PUT", "DELETE", "OPTIONS"]` |
| `cors_allow_headers` | Headers permitidos CORS | `["Content-Type", "Authorization", ...]` |
| `cors_max_age` | Max age CORS (segundos) | `300` |

### Outputs

| Output | Descrição |
|--------|-----------|
| `api_id` | ID do API Gateway |
| `api_endpoint` | Endpoint URL do API Gateway |
| `api_arn` | ARN do API Gateway |
| `stage_id` | ID do stage |
| `stage_invoke_url` | URL de invocação do stage |
| `stage_arn` | ARN do stage |
| `cloudwatch_log_group_name` | Nome do log group |
| `cloudwatch_log_group_arn` | ARN do log group |

## 🚀 Como Usar

### Pré-requisitos

1. Camada 0-bootstrap aplicada
2. Camada 1-networking aplicada

### 1. Inicializar Terraform

```bash
cd terraform/4-api-gateway
terraform init
```

### 2. Planejar

```bash
terraform plan
```

### 3. Aplicar

```bash
terraform apply
```

### 4. Obter URL da API

```bash
terraform output stage_invoke_url
```

### 5. Testar API

```bash
# Obter URL
API_URL=$(terraform output -raw stage_invoke_url)

# Testar (quando rotas estiverem configuradas)
curl $API_URL/health
```

## 📊 Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                  Internet                           │
└─────────────────────┬───────────────────────────────┘
                      │
                      │ HTTPS
                      │
┌─────────────────────▼───────────────────────────────┐
│            API Gateway HTTP API                     │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  Stage: dev                                  │  │
│  │  - Auto Deploy: Enabled                      │  │
│  │  - CORS: Configured                          │  │
│  │  - Logging: CloudWatch                       │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
                      │
                      │ (Future: VPC Link)
                      │
┌─────────────────────▼───────────────────────────────┐
│              Private VPC                            │
│         (Backend Services in EKS)                   │
└─────────────────────────────────────────────────────┘
```

## 🔄 Dependências

### Depende de:
- ✅ 0-bootstrap (bucket S3 para state)
- ✅ 1-networking (VPC e subnets para VPC Link futuro)

### É usado por:
- Aplicações frontend
- Clientes externos
- Integrações de terceiros

## 📝 Próximos Passos

Para completar a configuração do API Gateway:

### 1. Criar VPC Link

Descomente e configure o VPC Link em [`main.tf`](main.tf:75):

```hcl
resource "aws_security_group" "vpc_link" {
  # ... configuração
}

resource "aws_apigatewayv2_vpc_link" "main" {
  # ... configuração
}
```

### 2. Adicionar Integrações

Configure integrações com seus backends:

```hcl
resource "aws_apigatewayv2_integration" "backend" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://backend-service"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id
}
```

### 3. Configurar Rotas

Adicione rotas para seus endpoints:

```hcl
resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}
```

## ⚠️ Importante

- CORS está configurado para permitir todas as origens (`*`) - ajuste para produção
- Logs são retidos por 7 dias - ajuste conforme necessidade
- VPC Link e integrações estão comentados - habilite quando backend estiver pronto
- Auto-deploy está habilitado - mudanças são aplicadas automaticamente

## 🔐 Segurança

- API Gateway usa HTTPS por padrão
- CORS configurado (ajuste origins para produção)
- Logs estruturados no CloudWatch
- VPC Link (quando habilitado) mantém tráfego privado
- Security Group (quando habilitado) controla acesso

## 💰 Custos

Principais componentes de custo:
- **API Gateway**: Por milhão de requisições (~$1.00/milhão)
- **CloudWatch Logs**: Por GB armazenado e ingerido
- **VPC Link** (quando habilitado): ~$0.01/hora + data transfer

## 🗑️ Destruição

Para destruir esta camada:

```bash
cd terraform/4-api-gateway
terraform destroy
```

**Nota**: Esta camada pode ser destruída independentemente das outras.

## 🔧 Troubleshooting

### API não responde
- Verifique se stage está criado
- Confirme auto-deploy está habilitado
- Verifique logs no CloudWatch

### CORS errors
- Ajuste `cors_allow_origins` nas variáveis
- Verifique headers permitidos
- Confirme métodos HTTP permitidos

### Logs não aparecem
- Verifique permissões do API Gateway para CloudWatch
- Confirme log group existe
- Verifique formato de log configurado

## 📝 Notas

- API Gateway HTTP API é mais simples e barato que REST API
- CORS está pré-configurado para desenvolvimento
- Logging estruturado facilita debugging
- VPC Link permite integração segura com recursos privados
- Templates comentados facilitam expansão futura