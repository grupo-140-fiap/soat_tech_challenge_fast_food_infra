# 🏗️ Infraestrutura Terraform - Tech Challenge Fast Food

## 📋 Visão Geral

Este repositório contém a infraestrutura como código (IaC) do projeto Tech Challenge Fast Food, organizada em camadas independentes com states isolados para melhor performance, manutenção e escalabilidade.

## 🎯 Arquitetura

A infraestrutura está dividida em **5 camadas independentes**:

```
terraform/
├── 0-bootstrap/          # S3 bucket para states
├── 1-networking/         # VPC, subnets, gateways
├── 2-eks/               # Cluster EKS e nodes
├── 3-kubernetes/        # Helm charts e add-ons
├── 4-api-gateway/       # API Gateway HTTP
├── scripts/             # Scripts de automação
└── docs/                # Documentação detalhada
```

## 🚀 Quick Start

### Pré-requisitos

- **Terraform**: ~> 1.13.2
- **AWS CLI**: Configurado com perfil `default`
- **kubectl**: Para gerenciar Kubernetes
- **Permissões AWS**: Adequadas para criar recursos

### Deploy Rápido

```bash
# 1. Validar configurações
./terraform/scripts/validate-all.sh

# 2. Deploy completo (25-30 minutos)
./terraform/scripts/deploy-all.sh

# 3. Verificar deployment
kubectl get nodes
kubectl get pods -A
```

### Destruir Infraestrutura

```bash
# Destruir tudo (requer confirmação)
./terraform/scripts/destroy-all.sh
```

## 📊 Camadas Detalhadas

### 0-Bootstrap
**Propósito**: Bucket S3 para armazenar Terraform states

**Recursos**:
- S3 Bucket com versionamento
- Criptografia AES256
- Lifecycle policy (90 dias)

**Documentação**: [`0-bootstrap/README.md`](0-bootstrap/README.md)

---

### 1-Networking
**Propósito**: Infraestrutura de rede base

**Recursos**:
- VPC (10.0.0.0/16)
- 2 Subnets públicas (Multi-AZ)
- 2 Subnets privadas (Multi-AZ)
- Internet Gateway + NAT Gateway
- Route Tables

**Documentação**: [`1-networking/README.md`](1-networking/README.md)

---

### 2-EKS
**Propósito**: Cluster Kubernetes gerenciado

**Recursos**:
- EKS Cluster (v1.29)
- Node Group (t3.medium, 1-2 nodes)
- IAM Roles e Policies
- Pod Identity Addon

**Documentação**: [`2-eks/README.md`](2-eks/README.md)

---

### 3-Kubernetes
**Propósito**: Add-ons e componentes Kubernetes

**Recursos**:
- Metrics Server (Helm)
- Cluster Autoscaler (Helm)
- IAM Roles para service accounts

**Documentação**: [`3-kubernetes/README.md`](3-kubernetes/README.md)

---

### 4-API-Gateway
**Propósito**: Exposição de APIs

**Recursos**:
- API Gateway HTTP API
- CloudWatch Logs
- CORS configurado
- Preparado para VPC Link

**Documentação**: [`4-api-gateway/README.md`](4-api-gateway/README.md)

## 🔄 Fluxo de Dependências

```mermaid
graph TD
    A[0-bootstrap] --> B[1-networking]
    B --> C[2-eks]
    C --> D[3-kubernetes]
    B --> E[4-api-gateway]
```

## 📚 Documentação

### Guias Principais

- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)**: Guia completo de deployment
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Arquitetura detalhada
- **[Scripts README](scripts/README.md)**: Documentação dos scripts

### READMEs por Camada

Cada camada possui seu próprio README com:
- Recursos criados
- Variáveis disponíveis
- Outputs exportados
- Instruções de uso
- Troubleshooting

## 🛠️ Scripts Disponíveis

### deploy-all.sh
Deploy completo de todas as camadas

```bash
./terraform/scripts/deploy-all.sh
```

### destroy-all.sh
Destruição completa (ordem reversa)

```bash
./terraform/scripts/destroy-all.sh
```

### validate-all.sh
Validação de todas as configurações

```bash
./terraform/scripts/validate-all.sh
```

## 🔐 Segurança

### Network Security
- Recursos em subnets privadas
- NAT Gateway para acesso internet
- Security Groups configurados
- VPC Link preparado (future)

### IAM Security
- Roles com least privilege
- Pod Identity para workloads
- Service accounts dedicados

### Data Security
- States criptografados (S3)
- Versionamento habilitado
- HTTPS/TLS em todas comunicações

## 💰 Custos Estimados

### Ambiente Dev (Mensal)

| Componente | Custo Aproximado |
|------------|------------------|
| EKS Control Plane | ~$73 |
| EC2 Nodes (2x t3.medium) | ~$60 |
| NAT Gateway | ~$32 |
| API Gateway | ~$1/milhão req |
| CloudWatch Logs | Variável |
| S3 States | < $1 |
| **Total** | **~$170-200** |

## 📈 Escalabilidade

### Horizontal Pod Autoscaler (HPA)
- Baseado em CPU/Memory
- Metrics Server habilitado
- Min/Max configurável

### Cluster Autoscaler
- Auto-scaling de nodes
- Baseado em demanda de pods
- Scale down automático

## 🔍 Monitoramento

### Métricas Disponíveis
- CPU/Memory dos nodes
- Métricas de pods
- API Gateway logs
- CloudWatch integration

### Comandos Úteis

```bash
# Métricas de nodes
kubectl top nodes

# Métricas de pods
kubectl top pods -A

# Logs do Cluster Autoscaler
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler

# API Gateway URL
cd terraform/4-api-gateway
terraform output stage_invoke_url
```

## 🚨 Troubleshooting

### Cluster não acessível

```bash
# Reconfigurar kubectl
aws eks update-kubeconfig \
  --name eks-soat-fast-food-dev \
  --region us-east-1 \
  --profile default
```

### Metrics Server não funciona

```bash
# Verificar logs
kubectl logs -n kube-system -l k8s-app=metrics-server

# Verificar deployment
kubectl get deployment metrics-server -n kube-system
```

### State lock (se ocorrer)

```bash
# Como não usamos DynamoDB, não há locks automáticos
# Certifique-se de não executar terraform em paralelo
```

## 🎯 Próximos Passos

Após deployment:

1. **Aplicações**: Deploy de workloads no Kubernetes
2. **API Gateway**: Configurar rotas e integrações
3. **Monitoramento**: Implementar Prometheus/Grafana
4. **CI/CD**: Configurar pipelines automatizados
5. **Segurança**: Implementar WAF e rate limiting

## 🔄 Atualizações

### Atualizar uma Camada

```bash
cd terraform/2-eks
terraform plan
terraform apply
```

### Atualizar Versão do Kubernetes

```bash
# Editar variável em 2-eks/variables.tf
# cluster_version = "1.30"

cd terraform/2-eks
terraform apply
```

## 📝 Convenções

### Nomenclatura
- Recursos: `{project}-{resource}-{env}`
- Tags obrigatórias: `Name`, `Environment`, `Project`

### Versionamento
- Terraform: ~> 1.13.2
- AWS Provider: ~> 5.0
- Kubernetes Provider: ~> 2.20
- Helm Provider: ~> 2.11

## 🤝 Contribuindo

1. Validar mudanças: `./terraform/scripts/validate-all.sh`
2. Testar em ambiente dev
3. Documentar alterações
4. Atualizar READMEs relevantes

## 📞 Suporte

Para questões ou problemas:
1. Consultar documentação em `docs/`
2. Verificar READMEs das camadas
3. Revisar troubleshooting guides

## 📄 Licença

Este projeto faz parte do Tech Challenge - FIAP/SOAT

---

**Última atualização**: 2025-01-04
**Versão**: 1.0.0