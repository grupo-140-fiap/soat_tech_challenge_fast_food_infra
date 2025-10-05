# Fast Food Helm Chart

Este Helm Chart deploya o Sistema de Autoatendimento no Kubernetes com todas as dependências necessárias.

## 📋 Pré-requisitos

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support no cluster para persistência

## 🚀 Instalação

### 1. Instalação Básica
```bash
helm install fast-food ./helm/fast-food
```

### 2. Instalação com Valores Customizados
```bash
cat > my-values.yaml <<EOF
app:
  image:
    tag: "v2.0.0"
  autoscaling:
    minReplicas: 3
    maxReplicas: 15

mysql:
  auth:
    rootPassword: "minha-senha-segura"
    
secrets:
  DB_PASSWORD: "bWluaGEtc2VuaGEtc2VndXJh"  # base64: minha-senha-segura
  ACCESSTOKEN: "c2V1X3Rva2VuX21lcmNhZG9wYWdv"  # base64: seu_token_mercadopago
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
| `mysql.enabled` | Habilitar MySQL | `true` |
| `mysql.persistence.enabled` | Persistência MySQL | `true` |
| `mysql.persistence.size` | Tamanho do volume | `10Gi` |

### Variáveis de Ambiente

```yaml
env:
  DB_HOST: "fast-food-mysql"
  DB_PORT: "3306"
  DB_NAME: "fast_food_db"
  PORT: "8080"
  GIN_MODE: "release"
```

### Secrets

```yaml
secrets:
  # Senha do banco (base64)
  DB_PASSWORD: "cm9vdA=="  # root
  
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

# MySQL
kubectl logs -f deployment/fast-food-mysql

# Todos os componentes
kubectl logs -f -l app.kubernetes.io/instance=fast-food
```

## 🗑️ Desinstalação

```bash
# Remover release
helm uninstall fast-food

# Remover namespace (se criado pelo chart)
kubectl delete namespace fast-food

# Verificar PVCs remanescentes
kubectl get pvc -l app.kubernetes.io/instance=fast-food
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
- **MySQL**: `fast-food-mysql` (porta 3306)

### Acesso Externo
```bash

# Via Port-Forward
kubectl port-forward service/fast-food-api-clusterip 8080:8080 -n fast-food
```