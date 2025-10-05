# 2-EKS - Amazon EKS Cluster

## 📋 Descrição

Esta camada cria o cluster Amazon EKS (Elastic Kubernetes Service) com node groups e todas as configurações IAM necessárias.

## 🎯 Recursos Criados

### EKS Cluster
- **Nome**: eks-soat-fast-food-dev
- **Versão**: 1.32
- **Endpoint**: Público habilitado, privado desabilitado
- **Authentication Mode**: API
- **Pod Identity Addon**: v1.3.8-eksbuild.2
- **Control Plane Logs**: api, audit, authenticator, controllerManager, scheduler

### IAM Roles
- **Cluster Role**: Permissões para o control plane do EKS
- **Node Group Role**: Permissões para os worker nodes
  - AmazonEKSWorkerNodePolicy
  - AmazonEKS_CNI_Policy
  - AmazonEC2ContainerRegistryReadOnly

### Node Group
- **Tipo**: ON_DEMAND
- **Instâncias**: t3.micro
- **Scaling**:
  - Desired: 1
  - Min: 1
  - Max: 2
- **Subnets**: Privadas (da camada networking)

## ⚙️ Configuração

### Backend

Esta camada usa S3 como backend remoto:
- **Bucket**: soat-fast-food-terraform-states
- **Key**: 2-eks/terraform.tfstate
- **Region**: us-east-1
- **Encryption**: Habilitada

### Dependências

Esta camada depende da camada **1-networking** via `terraform_remote_state`:
- Busca subnet IDs das subnets privadas
- Usa VPC criada na camada anterior

### Variáveis

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `aws_profile` | Perfil AWS CLI | `default` |
| `project_name` | Nome do projeto | `soat-fast-food` |
| `environment` | Ambiente | `dev` |
| `cluster_name` | Nome do cluster EKS | `eks-soat-fast-food-dev` |
| `cluster_version` | Versão do Kubernetes | `1.32` |
| `cluster_log_types` | Logs do control plane habilitados | `["api","audit","authenticator","controllerManager","scheduler"]` |
| `endpoint_private_access` | Habilitar endpoint privado | `false` |
| `endpoint_public_access` | Habilitar endpoint público | `true` |
| `public_access_cidrs` | CIDRs permitidos no endpoint público | `["0.0.0.0/0"]` |
| `pod_identity_addon_version` | Versão do Pod Identity addon | `v1.3.8-eksbuild.2` |
| `node_group_capacity_type` | Tipo de capacidade | `ON_DEMAND` |
| `node_group_instance_types` | Tipos de instância | `["t3.micro"]` |
| `node_group_desired_size` | Tamanho desejado | `1` |
| `node_group_min_size` | Tamanho mínimo | `1` |
| `node_group_max_size` | Tamanho máximo | `2` |

### Outputs

| Output | Descrição |
|--------|-----------|
| `cluster_id` | ID do cluster EKS |
| `cluster_name` | Nome do cluster EKS |
| `cluster_endpoint` | Endpoint da API do cluster |
| `cluster_version` | Versão do Kubernetes |
| `cluster_certificate_authority` | Certificado CA do cluster (sensível) |
| `cluster_security_group_id` | ID do security group do cluster |
| `cluster_iam_role_arn` | ARN da role IAM do cluster |
| `node_group_id` | ID do node group |
| `node_group_arn` | ARN do node group |
| `node_group_status` | Status do node group |
| `node_group_iam_role_arn` | ARN da role IAM do node group |
| `oidc_provider_arn` | URL do issuer OIDC do cluster |

## 🚀 Como Usar

### Pré-requisitos

1. Camada 0-bootstrap aplicada
2. Camada 1-networking aplicada
3. AWS CLI configurado com perfil `default`

### 1. Inicializar Terraform

```bash
cd terraform/2-eks
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

### 4. Configurar kubectl

Após a criação do cluster, configure o kubectl:

```bash
aws eks update-kubeconfig --name eks-soat-fast-food-dev --region us-east-1 --profile default
```

### 5. Verificar Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

## 📊 Arquitetura

```
┌─────────────────────────────────────────────────────┐
│              EKS Control Plane                      │
│         (Gerenciado pela AWS)                       │
└─────────────────────────────────────────────────────┘
                        │
                        │ API Server
                        │
┌─────────────────────────────────────────────────────┐
│                  Node Group                         │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   Worker     │              │   Worker     │   │
│  │   Node 1     │              │   Node 2     │   │
│  │   t3.micro   │              │   t3.micro   │   │
│  │              │              │              │   │
│  │ Private      │              │ Private      │   │
│  │ Subnet AZ1   │              │ Subnet AZ2   │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

## 🔄 Dependências

### Depende de:
- ✅ 0-bootstrap (bucket S3 para state)
- ✅ 1-networking (VPC e subnets)

### É usado por:
- ⏭️ 3-kubernetes (Helm charts e addons)

## ⚠️ Importante

- O cluster leva ~10-15 minutos para ser criado
- Os nodes levam ~5 minutos adicionais
- O endpoint público está habilitado para facilitar acesso
- Pod Identity addon é necessário para IAM roles for service accounts
- O node group tem `ignore_changes` no `desired_size` para evitar conflitos com autoscaling

## 🔐 Segurança

- Cluster usa IAM roles com least privilege
- Nodes estão em subnets privadas
- Acesso à internet via NAT Gateway
- Pod Identity habilitado para workloads
- Bootstrap cluster creator admin permissions habilitado
- Endpoint público pode ser restringido via `public_access_cidrs` (padrão aberto)

## 💰 Custos

Principais componentes de custo:
- **EKS Control Plane**: ~$0.10/hora (~$73/mês)
- **EC2 Instances (t3.micro)**: custo on-demand baixo (elegível ao Free Tier)
- **NAT Gateway**: ~$0.045/hora + data transfer
- **EBS Volumes**: Incluídos com nodes

## 🗑️ Destruição

Para destruir esta camada, **primeiro destrua as camadas dependentes**:

```bash
# Destruir camadas dependentes primeiro
cd ../3-kubernetes && terraform destroy

# Então destruir EKS
cd ../2-eks && terraform destroy
```

## 🔧 Troubleshooting

### Cluster não cria
- Verifique se a camada networking está aplicada
- Confirme que as subnets privadas existem
- Verifique permissões IAM

### Nodes não aparecem
- Aguarde 5-10 minutos após criação do cluster
- Verifique logs do node group no console AWS
- Confirme que NAT Gateway está funcionando

### kubectl não conecta
- Execute `aws eks update-kubeconfig` novamente
- Verifique credenciais AWS
- Confirme que endpoint público está habilitado

## 📝 Notas

- O cluster usa authentication mode "API" para compatibilidade
- Bootstrap cluster creator default permissions facilita acesso inicial
- Node group usa lifecycle ignore_changes para desired_size
- Pod Identity addon é necessário para próxima camada (kubernetes)
