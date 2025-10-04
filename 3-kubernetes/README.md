# 3-Kubernetes - Kubernetes Add-ons and Helm Charts

## 📋 Descrição

Esta camada instala componentes essenciais do Kubernetes usando Helm, incluindo Metrics Server e Cluster Autoscaler.

## 🎯 Recursos Criados

### Metrics Server
- **Chart**: kubernetes-sigs/metrics-server
- **Version**: 3.12.1
- **Namespace**: kube-system
- **Função**: Coleta métricas de recursos (CPU/Memory) dos pods e nodes

### Cluster Autoscaler
- **Chart**: kubernetes/autoscaler
- **Version**: 9.37.0
- **Namespace**: kube-system
- **Função**: Escala automaticamente nodes baseado na demanda de pods

### IAM Resources
- **Cluster Autoscaler Role**: IAM role para o cluster autoscaler
- **Cluster Autoscaler Policy**: Permissões para gerenciar Auto Scaling Groups
- **Pod Identity Association**: Associação entre service account e IAM role

## ⚙️ Configuração

### Backend

Esta camada usa S3 como backend remoto:
- **Bucket**: soat-fast-food-terraform-states
- **Key**: 3-kubernetes/terraform.tfstate
- **Region**: us-east-1
- **Encryption**: Habilitada

### Dependências

Esta camada depende da camada **2-eks** via `terraform_remote_state`:
- Busca informações do cluster EKS
- Usa cluster name, endpoint e certificados
- Configura providers Kubernetes e Helm

### Providers

- **AWS**: Gerenciamento de recursos IAM
- **Kubernetes**: Configurado com credenciais do EKS
- **Helm**: Configurado com credenciais do EKS

### Variáveis

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `aws_profile` | Perfil AWS CLI | `default` |
| `project_name` | Nome do projeto | `soat-fast-food` |
| `environment` | Ambiente | `dev` |
| `metrics_server_version` | Versão do Metrics Server | `3.12.1` |
| `cluster_autoscaler_version` | Versão do Cluster Autoscaler | `9.37.0` |

### Outputs

| Output | Descrição |
|--------|-----------|
| `metrics_server_status` | Status do Helm release do Metrics Server |
| `cluster_autoscaler_status` | Status do Helm release do Cluster Autoscaler |
| `cluster_autoscaler_role_arn` | ARN da IAM role do Cluster Autoscaler |

## 🚀 Como Usar

### Pré-requisitos

1. Camada 0-bootstrap aplicada
2. Camada 1-networking aplicada
3. Camada 2-eks aplicada
4. kubectl configurado para o cluster

### 1. Inicializar Terraform

```bash
cd terraform/3-kubernetes
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

### 4. Verificar Instalação

```bash
# Verificar Metrics Server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods -A

# Verificar Cluster Autoscaler
kubectl get deployment cluster-autoscaler -n kube-system
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler
```

## 📊 Componentes

### Metrics Server

O Metrics Server coleta métricas de recursos dos nodes e pods:

```yaml
# Configuração customizada em values/metrics-server.yaml
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
```

**Uso:**
- Habilita `kubectl top nodes` e `kubectl top pods`
- Necessário para Horizontal Pod Autoscaler (HPA)
- Fornece métricas para dashboards

### Cluster Autoscaler

O Cluster Autoscaler gerencia o scaling de nodes:

**Permissões IAM:**
- Descrever Auto Scaling Groups
- Descrever instâncias EC2
- Modificar desired capacity
- Terminar instâncias

**Configuração:**
- Auto-discovery do cluster por tags
- Service Account com Pod Identity
- Região AWS configurada

## 🔄 Dependências

### Depende de:
- ✅ 0-bootstrap (bucket S3 para state)
- ✅ 2-eks (cluster EKS e configurações)

### É usado por:
- Aplicações que precisam de HPA
- Workloads que requerem auto-scaling

## ⚠️ Importante

- Metrics Server leva ~2-3 minutos para começar a coletar métricas
- Cluster Autoscaler precisa de permissões IAM corretas
- Pod Identity deve estar habilitado no cluster
- Values do Metrics Server podem precisar ajustes para ambientes específicos

## 🔐 Segurança

- Cluster Autoscaler usa Pod Identity (não IRSA)
- IAM role com least privilege
- Service account dedicado no kube-system
- Permissões limitadas a Auto Scaling Groups

## 💡 Troubleshooting

### Metrics Server não funciona
```bash
# Verificar logs
kubectl logs -n kube-system -l k8s-app=metrics-server

# Verificar se está rodando
kubectl get pods -n kube-system | grep metrics-server

# Testar métricas
kubectl top nodes
```

### Cluster Autoscaler não escala
```bash
# Verificar logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler

# Verificar Pod Identity
kubectl describe sa cluster-autoscaler -n kube-system

# Verificar IAM role
aws iam get-role --role-name <cluster-name>-cluster-autoscaler
```

### Erro de permissões
- Verifique se Pod Identity addon está instalado
- Confirme que IAM role tem policies corretas
- Verifique trust relationship da role

## 📝 Notas

- Metrics Server usa configuração customizada via values file
- Cluster Autoscaler usa auto-discovery por cluster name
- Pod Identity é preferível a IRSA para novos clusters
- Ambos os componentes rodam no namespace kube-system

## 🗑️ Destruição

Para destruir esta camada:

```bash
cd terraform/3-kubernetes
terraform destroy
```

**Nota**: Destrua esta camada antes de destruir a camada 2-eks.