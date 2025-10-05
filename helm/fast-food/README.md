# Fast Food Helm Chart

Este Helm Chart deploya o Sistema de Autoatendimento no Kubernetes. O banco de dados não é criado no cluster — utilize um RDS externo e forneça as variáveis de conexão via valores.

## 📋 Pré-requisitos

- Kubernetes 1.19+
- Helm 3.2.0+
 

## 🚀 Instalação

### 1. Instalação Básica
```bash
helm install fast-food ./helm/fast-food
```

### 2. Instalação com Valores Customizados (RDS externo)
```bash
cat > my-values.yaml <<EOF
app:
  image:
    tag: "v2.0.0"
  autoscaling:
    minReplicas: 3
    maxReplicas: 15

env:
  DB_HOST: "seu-endpoint-rds.rds.amazonaws.com"
  DB_PORT: "3306"
  DB_NAME: "seu_banco"
  DB_USER: "seu_usuario"

secrets:
  DB_PASSWORD: "bWluaGEtc2VuaGEtc2VndXJh"  # base64
  ACCESSTOKEN: "c2V1X3Rva2VuX21lcmNhZG9wYWdv"  # base64
EOF

helm install fast-food ./helm/fast-food -f my-values.yaml
```

### 3. Instalação em Namespace Específico
```bash
kubectl create namespace producao
helm install fast-food ./helm/fast-food -n producao --set namespace.name=producao
```

## ⚙️ Configuração

### Valores Principais

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `app.image.repository` | Repositório da imagem | `fast-food-api` |
| `app.image.tag` | Tag da imagem | `latest` |
| `app.autoscaling.enabled` | Habilitar HPA | `true` |
| `app.autoscaling.minReplicas` | Mínimo de réplicas | `2` |
| `app.autoscaling.maxReplicas` | Máximo de réplicas | `10` |
| `env.DB_HOST` | Endpoint do RDS | `"your-rds-endpoint.rds.amazonaws.com"` |
| `env.DB_PORT` | Porta do RDS | `"3306"` |
| `env.DB_NAME` | Nome do banco | `"your_db_name"` |
| `env.DB_USER` | Usuário do banco | `"your_db_user"` |

### Variáveis de Ambiente

```yaml
env:
  DB_HOST: "seu-endpoint-rds.rds.amazonaws.com"
  DB_PORT: "3306"
  DB_NAME: "seu_banco"
  DB_USER: "seu_usuario"
  PORT: "8080"
  GIN_MODE: "release"
```

### Secrets

```yaml
secrets:
  # Senha do banco (base64)
  DB_PASSWORD: "eW91cl9iYXNlNjRfZW5jb2RlZF9wYXNzd29yZA=="

  # Token MercadoPago (base64) 
  ACCESSTOKEN: "c2V1X3Rva2VuX21lcmNhZG9wYWdv"
```

## 🔧 Comandos Úteis

### Verificar Status
```bash
# Status do release
helm status fast-food

# Listar recursos
kubectl get all -l app.kubernetes.io/instance=fast-food

# Logs da aplicação
kubectl logs -f deployment/fast-food -l app.kubernetes.io/name=fast-food
```

### Atualizações
```bash
# Upgrade do chart
helm upgrade fast-food ./helm/fast-food

# Upgrade com novos valores
helm upgrade fast-food ./helm/fast-food -f my-values.yaml

# Rollback
helm rollback fast-food 1
```

### Debug
```bash
# Verificar templates gerados
helm template fast-food ./helm/fast-food

# Debug com valores
helm template fast-food ./helm/fast-food -f my-values.yaml

# Teste de conectividade
kubectl run test-pod --rm -i --tty --image=busybox -- /bin/sh
# Dentro do pod: wget -q -O- http://fast-food.fast-food.svc.cluster.local/health
```

## 📊 Monitoramento

### Health Checks
- **Liveness Probe**: `GET /health` (30s delay, 10s interval)
- **Readiness Probe**: `GET /health` (5s delay, 5s interval)

### Métricas HPA
- **CPU**: Scale quando > 70%
- **Memory**: Scale quando > 80%
- **Min/Max**: 2-10 pods

### Logs
```bash
# Aplicação
kubectl logs -f deployment/fast-food

# Todos os componentes
kubectl logs -f -l app.kubernetes.io/instance=fast-food
```

## 🗑️ Desinstalação

```bash
# Remover release
helm uninstall fast-food

# Remover namespace (se criado pelo chart)
kubectl delete namespace fast-food

```

## 🔒 Segurança

### ⚠️ Melhores Práticas de Secrets

**IMPORTANTE**: A abordagem atual de secrets inclusos no Helm Chart **NÃO é recomendada para ambientes de produção**.

#### Para Produção, Use:

1. **External Secrets Operator** (Recomendado):
```bash
# Instalar External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace

# Criar SecretStore apontando para seu provider (Vault, AWS Secrets Manager, etc.)
```

2. **Secrets Externos via kubectl**:
```bash
# Criar secrets manualmente no cluster
kubectl create secret generic fast-food-secrets \
  --from-literal=DB_PASSWORD=sua-senha-real \
  --from-literal=ACCESSTOKEN=seu-token-mercadopago \
  -n fast-food
```

3. **Valores em arquivos separados** (não versionados):
```bash
# values-secrets.yaml (adicionar ao .gitignore)
helm install fast-food ./helm/fast-food -f values.yaml -f values-secrets.yaml
```

#### Decisão para Este Projeto

**Por que estamos usando secrets no chart?**
- ✅ **Ambiente de estudos**: Facilita deployment rápido
- ✅ **Simplicidade**: Menos passos para configurar
- ✅ **Demonstração**: Mostra funcionamento completo
- ❌ **Não usar em produção**: Secrets expostos no repositório

### Configurações Aplicadas
- **Non-root containers**: UID 65534
- **Security context**: `runAsNonRoot: true`
- **Resource limits**: CPU e memória limitados
- **Secrets**: Dados sensíveis em base64 (⚠️ apenas para estudos)
- **Service Account**: Conta de serviço dedicada

### Customização de Segurança
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  fsGroup: 65534

app:
  resources:
    limits:
      memory: "512Mi"
      cpu: "500m"
```

## 🌐 Networking

### Services Criados
- **ClusterIP**: `fast-food-clusterip` (porta 8080)

### Acesso Externo
```bash

# Via Port-Forward
kubectl port-forward service/fast-food-clusterip 8080:8080 -n fast-food
```
