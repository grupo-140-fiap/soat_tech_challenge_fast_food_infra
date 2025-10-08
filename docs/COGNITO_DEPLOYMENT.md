 # 🔐 Autenticação com Cognito — Guia de Deploy
 
 ## 📋 Visão Geral
 
 Guia completo para fazer o deploy do sistema de autenticação com Cognito e Lambda Authorizer para o projeto SOAT Fast Food.
 
 ## 🎯 Resumo da Arquitetura
 
 ```mermaid
 graph TB
     Client[Aplicação Cliente]
     APIGW[API Gateway]
     AuthLambda[Lambda Auth<br/>Duplo Propósito]
     Cognito[Cognito User Pool]
     RDS[(RDS MySQL)]
     Backend[EKS Backend]
     
     Client -->|1. POST /auth| APIGW
     APIGW -->|2. Invoca| AuthLambda
     AuthLambda -->|3. Consulta| RDS
     AuthLambda -->|4. Sincroniza/Gera| Cognito
     AuthLambda -->|5. Token JWT| APIGW
     APIGW -->|6. Resposta| Client
     
     Client -->|7. Requisição + JWT| APIGW
     APIGW -->|8. Valida| AuthLambda
     AuthLambda -->|9. Verifica| Cognito
     AuthLambda -->|10. Policy| APIGW
     APIGW -->|11. Encaminha| Backend
 ```
 
 ## 📦 Componentes
 
 1. **Cognito User Pool** — Autenticação e geração de JWT
 2. **Lambda Auth** — Função de duplo propósito (auth + authorizer)
 3. **API Gateway** — Rotas com integração ao authorizer
 4. **RDS MySQL** — Fonte de dados de clientes (source of truth)
 
 ## 🚀 Passos de Deploy
 
 ### Passo 1: Deploy da Infraestrutura do Cognito
 
 ```bash
 cd soat_tech_challenge_fast_food_infra/4-cognito
 
 # Inicializar Terraform
 terraform init
 
 # Revisar o plano
 terraform plan \
   -var="db_password=SUA_SENHA_DO_DB"
 
 # Aplicar
 terraform apply \
   -var="db_password=SUA_SENHA_DO_DB"
 
 # Salvar outputs
 terraform output > outputs.txt
 ```
 
 **Outputs esperados:**
 - `cognito_user_pool_id`
 - `cognito_client_id`
 - `lambda_auth_function_name`
 - `lambda_auth_invoke_arn`
 - `lambda_packages_bucket_name`
 
 ### Passo 2: Publicar o Código da Lambda
 
 #### Opção A: Deploy Manual
 
 ```bash
 cd soat_tech_challenge_fast_food_lambda/auth
 
 # Instalar dependências
 npm install --production
 
 # Criar pacote de deployment
 zip -r lambda.zip src/ node_modules/
 
 # Enviar para o S3
 aws s3 cp lambda.zip s3://soat-fast-food-lambda-packages-dev/auth/lambda.zip
 
 # Atualizar a função Lambda
 aws lambda update-function-code \
   --function-name soat-fast-food-auth-dev \
   --s3-bucket soat-fast-food-lambda-packages-dev \
   --s3-key auth/lambda.zip
 ```
 
 #### Opção B: Automatizado via GitHub Actions
 
 ```bash
 # Fazer push na branch main
 git add .
 git commit -m "Deploy Lambda auth function"
 git push origin main
 
 # O GitHub Actions executa automaticamente:
 # 1. Build do pacote
 # 2. Upload para o S3
 # 3. Atualização da função Lambda
 ```
 
 ### Passo 3: Atualizar API Gateway
 
 ```bash
 cd soat_tech_challenge_fast_food_infra/5-api-gateway
 
 # Inicializar (se necessário)
 terraform init
 
 # Revisar mudanças
 terraform plan
 
 # Aplicar
 terraform apply
 
 # Obter URL do API Gateway
 terraform output stage_invoke_url
 ```
 
 **Mudanças esperadas:**
 - Authorizer (Cognito) criado
 - Rota `/auth` adicionada (pública)
 - Rota `/customers/{cpf}` adicionada (pública)
 - Rota `/{proxy+}` atualizada (protegida)
 
 ### Passo 4: Verificar o Deploy
 
 ```bash
 # Obter a URL do API Gateway
 API_URL=$(cd ../5-api-gateway && terraform output -raw stage_invoke_url)
 
 # Testar o endpoint de autenticação
 curl -X POST ${API_URL}/auth \
   -H "Content-Type: application/json" \
   -d '{"cpf":"12345678900"}'
 
 # Esperado: 404 (cliente não encontrado) ou 200 (com token)
 ```
 
 ## 🔧 Configuração
 
 ### Variáveis de Ambiente (Lambda)
 
 Definidas via Terraform em `4-cognito/lambda.tf`:
 
 ```hcl
 environment {
   variables = {
     DB_HOST              = "<rds-endpoint>"
     DB_PORT              = "3306"
     DB_NAME              = "fastfood"
     DB_USER              = "admin"
     DB_PASSWORD          = "<password>"
     COGNITO_USER_POOL_ID = "<pool-id>"
     COGNITO_CLIENT_ID    = "<client-id>"
     AWS_REGION_CUSTOM    = "us-east-1"
   }
 }
 ```
 
 ### Segredos do GitHub
 
 Configure nos settings do repositório:
 
 ```bash
 # Segredos necessários
 AWS_ACCESS_KEY_ID=<sua-access-key>
 AWS_SECRET_ACCESS_KEY=<seu-secret-key>
 ```
 
 ## 🧪 Testes
 
 ### 1. Criar Cliente de Teste (Backend)
 
 ```bash
 # Crie primeiro um cliente de teste
 curl -X POST ${API_URL}/customers \
   -H "Content-Type: application/json" \
   -d '{
     "first_name": "John",
     "last_name": "Doe",
     "cpf": "12345678900",
     "email": "john@example.com"
   }'
 ```
 
 ### 2. Testar Autenticação
 
 ```bash
 # Autenticar com CPF
 curl -X POST ${API_URL}/auth \
   -H "Content-Type: application/json" \
   -d '{"cpf":"12345678900"}'
 
 # Salvar o token
 TOKEN="<token-da-resposta>"
 ```
 
 ### 3. Testar Rota Pública
 
 ```bash
 # Deve funcionar sem token
 curl -X GET ${API_URL}/customers/12345678900
 ```
 
 ### 4. Testar Rota Protegida Sem Token
 
 ```bash
 # Deve retornar 401
 curl -X GET ${API_URL}/orders
 ```
 
 ### 5. Testar Rota Protegida com Token
 
 ```bash
 # Deve retornar 200
 curl -X GET ${API_URL}/orders \
   -H "Authorization: Bearer ${TOKEN}"
 ```
 
 ## 📊 Monitoramento
 
 ### Dashboards no CloudWatch
 
 Crie um dashboard para monitorar:
 
 ```bash
 # Métricas da Lambda
 - Invocations
 - Duration
 - Errors
 - Throttles
 
 # Métricas do API Gateway
 - 4XXError (falhas de auth)
 - 5XXError (erros de servidor)
 - Latency
 - Count
 ```
 
 ### Grupos de Log
 
 ```bash
 # Logs da Lambda
 /aws/lambda/soat-fast-food-auth-dev
 
 # Logs do API Gateway
 /aws/apigateway/soat-fast-food-api
 ```
 
 ### Comandos Úteis
 
 ```bash
 # Seguir logs da Lambda
 aws logs tail /aws/lambda/soat-fast-food-auth-dev --follow
 
 # Filtrar tentativas de autenticação
 aws logs filter-log-events \
   --log-group-name /aws/lambda/soat-fast-food-auth-dev \
   --filter-pattern "Authentication"
 
 # Filtrar tentativas de autorização
 aws logs filter-log-events \
   --log-group-name /aws/lambda/soat-fast-food-auth-dev \
   --filter-pattern "Authorization"
 ```
 
 ## 🔐 Checklist de Segurança
 
 - [ ] Senha do banco armazenada com segurança (fora do código)
 - [ ] Lambda em subnets privadas da VPC
 - [ ] Security groups configurados corretamente
 - [ ] IAM com least privilege
 - [ ] User Pool do Cognito com configurações adequadas
 - [ ] API Gateway apenas via HTTPS
 - [ ] CORS configurado corretamente
 - [ ] Segredos no GitHub protegidos
 - [ ] Proteção de branch habilitada na main
 
 ## 🚨 Troubleshooting
 
 ### Lambda não consegue conectar no RDS
 
 **Sintomas**: Timeout, connection refused
 
 **Soluções**:
 1. Verifique a configuração de VPC da Lambda
 2. Revise as regras dos security groups
 3. Garanta que a Lambda está em subnets privadas
 4. Confirme que o SG do RDS permite o SG da Lambda
 
 ```bash
 # Verificar VPC da Lambda
 aws lambda get-function-configuration \
   --function-name soat-fast-food-auth-dev \
   --query 'VpcConfig'
 
 # Conferir security groups
 aws ec2 describe-security-groups \
   --group-ids <lambda-sg-id> <rds-sg-id>
 ```
 
 ### Falha ao criar usuário no Cognito
 
 **Sintomas**: Erros no AdminCreateUser
 
 **Soluções**:
 1. Verificar permissões de IAM
 2. Validar configuração do User Pool
 3. Conferir atributos customizados
 
 ```bash
 # Testar acesso ao Cognito
 aws cognito-idp list-users \
   --user-pool-id <pool-id>
 
 # Conferir role da Lambda
 aws iam get-role-policy \
   --role-name soat-fast-food-lambda-auth-role-dev \
   --policy-name soat-fast-food-lambda-cognito-policy-dev
 ```
 
 ### Validação de JWT falhando
 
 **Sintomas**: 403 Forbidden em rotas protegidas
 
 **Soluções**:
 1. Verifique se o token não expirou
 2. Confira User Pool ID e Client ID
 3. Garanta que o token é do pool correto
 
 ```bash
 # Decodificar JWT (sem verificação)
 echo "<token>" | cut -d. -f2 | base64 -d | jq
 
 # Conferir expiração no claim "exp"
 ```
 
 ### Erros 500 no API Gateway
 
 **Sintomas**: Internal server errors
 
 **Soluções**:
 1. Verifique logs da Lambda
 2. Valide a configuração do authorizer
 3. Teste a Lambda de forma independente
 
 ```bash
 # Testar Lambda diretamente
 aws lambda invoke \
   --function-name soat-fast-food-auth-dev \
   --payload '{"body":"{\"cpf\":\"12345678900\"}"}' \
   response.json
 
 cat response.json
 ```
 
 ## 🔄 Atualizações e Manutenção
 
 ### Atualizar Código da Lambda
 
 ```bash
 # Fazer alterações
 cd soat_tech_challenge_fast_food_lambda/auth
 
 # Testar localmente
 npm test
 
 # Commit e push (aciona CI/CD)
 git add .
 git commit -m "Update Lambda function"
 git push origin main
 ```
 
 ### Atualizar Infraestrutura
 
 ```bash
 # Alterar arquivos Terraform
 cd soat_tech_challenge_fast_food_infra/4-cognito
 
 # Plan
 terraform plan
 
 # Apply
 terraform apply
 ```
 
 ### Rotacionar Credenciais
 
 ```bash
 # Atualizar senha do banco
 terraform apply \
   -var="db_password=NOVA_SENHA"
 
 # A Lambda será atualizada automaticamente
 ```
 
 ## 📈 Otimização de Performance
 
 ### Cache do Authorizer
 
 Atual: 5 minutos (300 segundos)
 
 ```hcl
 authorizer_result_ttl_in_seconds = 300
 ```
 
 **Considerações**:
 - Cache maior = melhor performance, atualização de permissões mais lenta
 - Cache menor = mais invocações da Lambda, custo maior
 
 ### Configuração da Lambda
 
 Configuração atual:
 - Memória: 512 MB
 - Timeout: 30 segundos
 - Runtime: Node.js 20.x
 
 **Otimização**:
 - Monitore métricas de duração
 - Ajuste memória conforme necessário
 - Considere provisioned concurrency para alto tráfego
 
 ## 📚 Recursos Adicionais
 
 - [Documentação da Camada Cognito](../4-cognito/README.md)
 - [Documentação da Função Lambda](../../soat_tech_challenge_fast_food_lambda/auth/README.md)
 - [Autenticação no API Gateway](../5-api-gateway/AUTHENTICATION.md)
 - [Boas Práticas do AWS Cognito](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-best-practices.html)
 
 ## 📝 Checklist de Deploy
 
 ### Pré-Deploy
 - [ ] Todas as camadas anteriores (0-3) aplicadas
 - [ ] Camada de banco aplicada
 - [ ] RDS acessível pela VPC
 - [ ] Segredos do GitHub configurados
 
 ### Deploy
 - [ ] Infraestrutura do Cognito aplicada
 - [ ] Código da Lambda publicado
 - [ ] API Gateway atualizado
 - [ ] Rotas configuradas corretamente
 
 ### Pós-Deploy
 - [ ] Autenticação testada
 - [ ] Autorização testada
 - [ ] Monitoramento configurado
 - [ ] Logs verificados
 - [ ] Documentação atualizada
 
 ### Validação
 - [ ] Rotas públicas funcionam sem token
 - [ ] Rotas protegidas exigem token
 - [ ] Tokens inválidos são rejeitados
 - [ ] Contexto de usuário chega no backend
 - [ ] Performance aceitável
 
 ---
 
 **Última atualização**: 2025-01-07  
 **Versão**: 1.0.0  
 **Mantido por**: Equipe SOAT Tech Challenge
