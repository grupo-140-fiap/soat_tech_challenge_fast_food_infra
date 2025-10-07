# 🔐 Autenticação no API Gateway

## 📋 Visão Geral

O API Gateway está configurado com autenticação baseada no Cognito usando um Lambda Authorizer. Isso permite validar tokens JWT para rotas protegidas enquanto mantém endpoints específicos públicos.

## 🏗️ Arquitetura

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant APIGateway as API Gateway
    participant Authorizer as Lambda Authorizer
    participant Auth as Lambda de Auth
    participant Backend as Backend em EKS
    
    Note over Client,Backend: Rota Pública - Autenticação
    Client->>APIGateway: POST /auth {cpf}
    APIGateway->>Auth: Invocar
    Auth-->>APIGateway: Token JWT
    APIGateway-->>Client: 200 OK + Token
    
    Note over Client,Backend: Rota Protegida - Com Autorização
    Client->>APIGateway: GET /orders (Bearer token)
    APIGateway->>Authorizer: Validar Token
    Authorizer-->>APIGateway: Policy Allow + Contexto
    APIGateway->>Backend: Encaminhar Requisição + Info do Usuário
    Backend-->>APIGateway: Resposta
    APIGateway-->>Client: 200 OK
```

## 🛣️ Configuração de Rotas

### Rotas Públicas (Sem Autenticação)

| Método | Rota | Integração | Descrição |
|--------|------|------------|-----------|
| POST | `/auth` | Lambda Auth | Autenticação de usuário por CPF |

### Rotas Protegidas (Requer JWT)

| Método | Rota | Integração | Descrição |
|--------|------|------------|-----------|
| ANY | `/{proxy+}` | Backend (VPC Link) | Todas as demais rotas |

**Exemplos de rotas protegidas:**
- `POST /customers` - Criar cliente
- `PUT /customers/{id}` - Atualizar cliente
- `DELETE /customers/{id}` - Remover cliente
- `GET /products` - Listar produtos
- `POST /products` - Criar produto
- `GET /orders` - Listar pedidos
- `POST /orders` - Criar pedido
- etc.

## 🔑 Fluxo de Autenticação

### 1. Obter Token JWT

```bash
# Requisição
curl -X POST https://sua-url-do-api-gateway/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678900"}'

# Resposta (Sucesso)
{
  "token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "user": {
    "id": 1,
    "cpf": "12345678900",
    "email": "user@example.com",
    "name": "John Doe"
  }
}

# Resposta (Erro - Cliente não encontrado)
{
  "error": "Customer not found",
  "message": "Cliente não encontrado. Por favor, cadastre-se primeiro."
}
```

### 2. Usar o Token em Rotas Protegidas

```bash
# Requisição com cabeçalho Authorization
curl -X GET https://sua-url-do-api-gateway/orders \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# Resposta
{
  "orders": [...]
}
```

## 📊 Contexto do Usuário

O authorizer repassa informações do usuário ao backend via contexto:

```javascript
// Backend recebe nos headers:
{
  "x-apigateway-context-customerId": "1",
  "x-apigateway-context-cpf": "12345678900",
  "x-apigateway-context-email": "user@example.com"
}
```

## 🧪 Testes

### Testar Rota Pública

```bash
# Deve funcionar sem token
curl -X POST https://sua-url-do-api-gateway/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678900"}'
```

### Testar Rota Protegida Sem Token

```bash
# Deve retornar 401 Unauthorized
curl -X GET https://sua-url-do-api-gateway/orders
```

### Testar Rota Protegida com Token Inválido

```bash
# Deve retornar 403 Forbidden
curl -X GET https://sua-url-do-api-gateway/orders \
  -H "Authorization: Bearer invalid-token"
```

### Testar Rota Protegida com Token Válido

```bash
# Deve retornar 200 OK
curl -X GET https://sua-url-do-api-gateway/orders \
  -H "Authorization: Bearer <valid-jwt-token>"
```

## 🔐 Segurança

### Validação do Token

O Lambda Authorizer valida:
1. **Assinatura do token**: Chaves públicas do Cognito
2. **Expiração**: Claim `exp`
3. **Emissor**: Claim `iss` compatível com o User Pool
4. **Audiência**: Claim `aud` compatível com o Client ID

### Boas Práticas

- ✅ Tokens expiram em 60 minutos
- ✅ Refresh tokens válidos por 30 dias
- ✅ Resultados do authorizer são cacheados por 5 minutos
- ✅ Somente HTTPS (forçado pelo API Gateway)
- ✅ CORS configurado para clientes web

## 📈 Monitoramento

### Métricas no CloudWatch

Monitore no CloudWatch:
- **4XXError**: Requisições não autorizadas/proibidas
- **5XXError**: Erros no authorizer
- **Latency**: Sobrecarga da autorização
- **Count**: Total de requisições

### Logs

```bash
# Ver logs do API Gateway
aws logs tail /aws/apigateway/soat-fast-food-api --follow

# Ver logs do Authorizer
aws logs tail /aws/lambda/soat-fast-food-auth-dev --follow \
  --filter-pattern "Authorization"
```