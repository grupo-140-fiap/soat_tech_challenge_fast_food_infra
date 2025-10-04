# 1-Networking - VPC and Network Infrastructure

## 📋 Descrição

Esta camada cria toda a infraestrutura de rede necessária para o projeto, incluindo VPC, subnets públicas e privadas, Internet Gateway, NAT Gateway e tabelas de roteamento.

## 🎯 Recursos Criados

### VPC
- **CIDR**: 10.0.0.0/16
- DNS Support e DNS Hostnames habilitados
- Tags para Kubernetes

### Subnets Privadas
- **Zone 1 (us-east-1a)**: 10.0.0.0/19
- **Zone 2 (us-east-1b)**: 10.0.32.0/19
- Tags para internal load balancers do Kubernetes

### Subnets Públicas
- **Zone 1 (us-east-1a)**: 10.0.64.0/19
- **Zone 2 (us-east-1b)**: 10.0.96.0/19
- Auto-assign public IP habilitado
- Tags para external load balancers do Kubernetes

### Gateways
- **Internet Gateway**: Para acesso à internet das subnets públicas
- **NAT Gateway**: Para acesso à internet das subnets privadas
- **Elastic IP**: Associado ao NAT Gateway

### Route Tables
- **Private Route Table**: Roteia tráfego 0.0.0.0/0 para NAT Gateway
- **Public Route Table**: Roteia tráfego 0.0.0.0/0 para Internet Gateway

## ⚙️ Configuração

### Backend

Esta camada usa S3 como backend remoto:
- **Bucket**: soat-fast-food-terraform-states
- **Key**: 1-networking/terraform.tfstate
- **Region**: us-east-1
- **Encryption**: Habilitada

### Variáveis

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `aws_profile` | Perfil AWS CLI | `elvismariel` |
| `project_name` | Nome do projeto | `soat-fast-food` |
| `environment` | Ambiente | `dev` |
| `vpc_cidr` | CIDR da VPC | `10.0.0.0/16` |
| `availability_zone_1` | Primeira AZ | `us-east-1a` |
| `availability_zone_2` | Segunda AZ | `us-east-1b` |
| `private_subnet_zone_1_cidr` | CIDR subnet privada AZ1 | `10.0.0.0/19` |
| `private_subnet_zone_2_cidr` | CIDR subnet privada AZ2 | `10.0.32.0/19` |
| `public_subnet_zone_1_cidr` | CIDR subnet pública AZ1 | `10.0.64.0/19` |
| `public_subnet_zone_2_cidr` | CIDR subnet pública AZ2 | `10.0.96.0/19` |
| `eks_cluster_name` | Nome do cluster EKS | `eks-soat-fast-food-dev` |

### Outputs

| Output | Descrição |
|--------|-----------|
| `vpc_id` | ID da VPC |
| `vpc_cidr` | CIDR da VPC |
| `private_subnet_ids` | Lista de IDs das subnets privadas |
| `public_subnet_ids` | Lista de IDs das subnets públicas |
| `private_subnet_zone_1_id` | ID da subnet privada na AZ1 |
| `private_subnet_zone_2_id` | ID da subnet privada na AZ2 |
| `public_subnet_zone_1_id` | ID da subnet pública na AZ1 |
| `public_subnet_zone_2_id` | ID da subnet pública na AZ2 |
| `internet_gateway_id` | ID do Internet Gateway |
| `nat_gateway_id` | ID do NAT Gateway |
| `nat_gateway_public_ip` | IP público do NAT Gateway |
| `private_route_table_id` | ID da route table privada |
| `public_route_table_id` | ID da route table pública |

## 🚀 Como Usar

### Pré-requisitos

1. Camada 0-bootstrap deve estar aplicada
2. Bucket S3 para states deve existir

### 1. Inicializar Terraform

```bash
cd terraform/1-networking
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

### 4. Verificar Outputs

```bash
terraform output
```

## 📊 Arquitetura de Rede

```
┌─────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                    │
│                                                         │
│  ┌──────────────────┐        ┌──────────────────┐     │
│  │   us-east-1a     │        │   us-east-1b     │     │
│  │                  │        │                  │     │
│  │  ┌────────────┐  │        │  ┌────────────┐  │     │
│  │  │  Public    │  │        │  │  Public    │  │     │
│  │  │ 10.0.64/19 │  │        │  │ 10.0.96/19 │  │     │
│  │  └─────┬──────┘  │        │  └──────┬─────┘  │     │
│  │        │         │        │         │        │     │
│  │  ┌─────▼──────┐  │        │  ┌──────▼─────┐  │     │
│  │  │  Private   │  │        │  │  Private   │  │     │
│  │  │ 10.0.0/19  │  │        │  │ 10.0.32/19 │  │     │
│  │  └────────────┘  │        │  └────────────┘  │     │
│  └──────────────────┘        └──────────────────┘     │
│                                                         │
│  ┌──────────────┐              ┌──────────────┐       │
│  │     IGW      │              │  NAT Gateway │       │
│  └──────────────┘              └──────────────┘       │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Dependências

### Depende de:
- ✅ 0-bootstrap (bucket S3 para state)

### É usado por:
- ⏭️ 2-eks (subnets para cluster e nodes)
- ⏭️ 4-api-gateway (VPC e subnets para VPC Link)

## ⚠️ Importante

- Esta camada deve ser aplicada **antes** das camadas 2-eks e 4-api-gateway
- As tags do Kubernetes nas subnets são essenciais para o funcionamento do EKS
- O NAT Gateway tem custo por hora, mesmo quando não está em uso
- Mudanças na VPC ou subnets podem impactar recursos dependentes

## 🗑️ Destruição

Para destruir esta camada, **primeiro destrua as camadas dependentes**:

```bash
# Destruir camadas dependentes primeiro
cd ../4-api-gateway && terraform destroy
cd ../3-kubernetes && terraform destroy
cd ../2-eks && terraform destroy

# Então destruir networking
cd ../1-networking && terraform destroy
```

## 📝 Notas

- Subnets privadas usam NAT Gateway para acesso à internet
- Subnets públicas têm acesso direto via Internet Gateway
- Route tables estão configuradas automaticamente
- Tags do Kubernetes permitem descoberta automática de subnets pelo EKS