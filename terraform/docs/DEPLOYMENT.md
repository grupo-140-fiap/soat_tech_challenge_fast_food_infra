# 🚀 Guia de Deployment - Infraestrutura Terraform

## 📋 Visão Geral

Este guia descreve o processo completo de deployment da infraestrutura do projeto Tech Challenge Fast Food, organizada em camadas independentes com states isolados.

## 🏗️ Arquitetura de Camadas

A infraestrutura está dividida em 5 camadas:

1. **0-bootstrap**: Bucket S3 para armazenamento de states
2. **1-networking**: VPC, subnets, gateways e rotas
3. **2-eks**: Cluster EKS e node groups
4. **3-kubernetes**: Helm charts e add-ons do Kubernetes
5. **4-api-gateway**: API Gateway HTTP

## ⚙️ Pré-requisitos

### Software Necessário

- **Terraform**: ~> 1.13.2
- **AWS CLI**: Configurado com perfil `elvismariel`
- **kubectl**: Para gerenciar o cluster Kubernetes
- **Git**: Para controle de versão

### Credenciais AWS

```bash
# Configurar AWS CLI
aws configure --profile elvismariel

# Verificar credenciais
aws sts get-caller-identity --profile elvismariel
```

## 📦 Ordem de Deployment

### Camada 0: Bootstrap

**Objetivo**: Criar bucket S3 para armazenar states remotos

```bash
cd terraform/0-bootstrap

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply

# Verificar outputs
terraform output
```

**Outputs importantes**:
- `state_bucket_name`: Nome do bucket S3 criado
- `state_bucket_region`: Região do bucket

**Tempo estimado**: 1-2 minutos

---

### Camada 1: Networking

**Objetivo**: Criar infraestrutura de rede (VPC, subnets, gateways)

```bash
cd terraform/1-networking

# Inicializar (conecta ao S3 backend)
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply

# Verificar outputs
terraform output
```

**Outputs importantes**:
- `vpc_id`: ID da VPC criada
- `private_subnet_ids`: IDs das subnets privadas
- `public_subnet_ids`: IDs das subnets públicas
- `nat_gateway_public_ip`: IP público do NAT Gateway

**Tempo estimado**: 3-5 minutos

---

### Camada 2: EKS

**Objetivo**: Criar cluster EKS e node groups

```bash
cd terraform/2-eks

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply

# Verificar outputs
terraform output
```

**Outputs importantes**:
- `cluster_name`: Nome do cluster EKS
- `cluster_endpoint`: Endpoint da API do cluster
- `cluster_version`: Versão do Kubernetes

**Tempo estimado**: 10-15 minutos

**Pós-deployment**:

```bash
# Configurar kubectl
aws eks update-kubeconfig \
  --name eks-soat-fast-food-dev \
  --region us-east-1 \
  --profile elvismariel

# Verificar nodes
kubectl get nodes

# Verificar pods do sistema
kubectl get pods -A
```

---

### Camada 3: Kubernetes

**Objetivo**: Instalar add-ons do Kubernetes (Metrics Server, Cluster Autoscaler)

```bash
cd terraform/3-kubernetes

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply

# Verificar outputs
terraform output
```

**Outputs importantes**:
- `metrics_server_status`: Status do Metrics Server
- `cluster_autoscaler_status`: Status do Cluster Autoscaler
- `cluster_autoscaler_role_arn`: ARN da role IAM

**Tempo estimado**: 5-7 minutos

**Pós-deployment**:

```bash
# Verificar Metrics Server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes

# Verificar Cluster Autoscaler
kubectl get deployment cluster-autoscaler -n kube-system
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler
```

---

### Camada 4: API Gateway

**Objetivo**: Criar API Gateway HTTP

```bash
cd terraform/4-api-gateway

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply

# Verificar outputs
terraform output
```

**Outputs importantes**:
- `api_id`: ID do API Gateway
- `stage_invoke_url`: URL de invocação da API
- `api_endpoint`: Endpoint base da API

**Tempo estimado**: 2-3 minutos

**Pós-deployment**:

```bash
# Obter URL da API
API_URL=$(terraform output -raw stage_invoke_url)
echo "API URL: $API_URL"
```

---

## 🔄 Deploy Completo (Script)

Para facilitar o deployment de todas as camadas:

```bash
#!/bin/bash
set -e

echo "🚀 Iniciando deployment completo..."

# Camada 0: Bootstrap
echo "📦 Camada 0: Bootstrap"
cd terraform/0-bootstrap
terraform init
terraform apply -auto-approve
cd ../..

# Camada 1: Networking
echo "🌐 Camada 1: Networking"
cd terraform/1-networking
terraform init
terraform apply -auto-approve
cd ../..

# Camada 2: EKS
echo "☸️  Camada 2: EKS"
cd terraform/2-eks
terraform init
terraform apply -auto-approve
cd ../..

# Configurar kubectl
echo "🔧 Configurando kubectl..."
aws eks update-kubeconfig \
  --name eks-soat-fast-food-dev \
  --region us-east-1 \
  --profile elvismariel

# Camada 3: Kubernetes
echo "📊 Camada 3: Kubernetes"
cd terraform/3-kubernetes
terraform init
terraform apply -auto-approve
cd ../..

# Camada 4: API Gateway
echo "🌍 Camada 4: API Gateway"
cd terraform/4-api-gateway
terraform init
terraform apply -auto-approve
cd ../..

echo "✅ Deploy completo finalizado!"
```

## 🗑️ Destruição da Infraestrutura

**IMPORTANTE**: Destruir na ordem REVERSA para evitar dependências quebradas.

### Ordem de Destruição

```bash
# 1. API Gateway
cd terraform/4-api-gateway
terraform destroy

# 2. Kubernetes
cd terraform/3-kubernetes
terraform destroy

# 3. EKS
cd terraform/2-eks
terraform destroy

# 4. Networking
cd terraform/1-networking
terraform destroy

# 5. Bootstrap (último)
cd terraform/0-bootstrap
terraform destroy
```

### Script de Destruição

```bash
#!/bin/bash
set -e

echo "🗑️  Iniciando destruição da infraestrutura..."

# Camada 4: API Gateway
echo "Destruindo Camada 4: API Gateway"
cd terraform/4-api-gateway
terraform destroy -auto-approve
cd ../..

# Camada 3: Kubernetes
echo "Destruindo Camada 3: Kubernetes"
cd terraform/3-kubernetes
terraform destroy -auto-approve
cd ../..

# Camada 2: EKS
echo "Destruindo Camada 2: EKS"
cd terraform/2-eks
terraform destroy -auto-approve
cd ../..

# Camada 1: Networking
echo "Destruindo Camada 1: Networking"
cd terraform/1-networking
terraform destroy -auto-approve
cd ../..

# Camada 0: Bootstrap
echo "Destruindo Camada 0: Bootstrap"
cd terraform/0-bootstrap
terraform destroy -auto-approve
cd ../..

echo "✅ Destruição completa finalizada!"
```

## 🔍 Validação

### Verificar States

```bash
# Listar states no S3
aws s3 ls s3://soat-fast-food-terraform-states/ --profile elvismariel

# Verificar state específico
aws s3 ls s3://soat-fast-food-terraform-states/1-networking/ --profile elvismariel
```

### Verificar Recursos AWS

```bash
# VPC
aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=soat-fast-food" \
  --profile elvismariel

# EKS Cluster
aws eks describe-cluster \
  --name eks-soat-fast-food-dev \
  --profile elvismariel

# API Gateway
aws apigatewayv2 get-apis \
  --profile elvismariel
```

### Verificar Kubernetes

```bash
# Nodes
kubectl get nodes

# Pods do sistema
kubectl get pods -A

# Metrics
kubectl top nodes
kubectl top pods -A
```

## ⚠️ Troubleshooting

### Erro: Backend não inicializado

```bash
# Solução: Aplicar bootstrap primeiro
cd terraform/0-bootstrap
terraform apply
```

### Erro: Subnet não encontrada

```bash
# Solução: Verificar se networking foi aplicado
cd terraform/1-networking
terraform output
```

### Erro: Cluster não acessível

```bash
# Solução: Reconfigurar kubectl
aws eks update-kubeconfig \
  --name eks-soat-fast-food-dev \
  --region us-east-1 \
  --profile elvismariel
```

### Erro: State lock

```bash
# Verificar locks (se DynamoDB estivesse habilitado)
# Como não usamos DynamoDB, não há locks automáticos
# Certifique-se de não executar terraform em paralelo
```

## 📊 Custos Estimados

### Custos Mensais Aproximados

- **EKS Control Plane**: ~$73/mês
- **EC2 Instances (t3.medium x2)**: ~$60/mês
- **NAT Gateway**: ~$32/mês + data transfer
- **API Gateway**: Baseado em uso (~$1/milhão de requests)
- **CloudWatch Logs**: Baseado em volume
- **S3 (States)**: < $1/mês

**Total estimado**: ~$170-200/mês (ambiente dev)

## 🔐 Segurança

### Checklist de Segurança

- [ ] Credenciais AWS configuradas com least privilege
- [ ] States criptografados no S3
- [ ] Versionamento habilitado no bucket de states
- [ ] Nodes em subnets privadas
- [ ] Security groups configurados corretamente
- [ ] CORS configurado adequadamente no API Gateway
- [ ] Logs habilitados para auditoria

## 📝 Notas Importantes

1. **States Isolados**: Cada camada tem seu próprio state, permitindo mudanças independentes
2. **Dependências**: Gerenciadas via `terraform_remote_state`
3. **Versionamento**: Bucket S3 mantém histórico de states (90 dias)
4. **Rollback**: Possível via versionamento do S3
5. **Paralelização**: Não execute terraform em paralelo na mesma camada

## 🎯 Próximos Passos

Após deployment completo:

1. Configurar aplicações no Kubernetes
2. Adicionar rotas e integrações no API Gateway
3. Configurar CI/CD pipelines
4. Implementar monitoramento e alertas
5. Configurar backup e disaster recovery