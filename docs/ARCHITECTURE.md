# 🏗️ Arquitetura da Infraestrutura - Tech Challenge Fast Food

## 📋 Visão Geral

Este documento descreve a arquitetura da infraestrutura do projeto Tech Challenge Fast Food, implementada com Terraform e organizada em camadas independentes.

## 🎯 Princípios de Design

### 1. Separação de Responsabilidades
- Cada camada tem uma responsabilidade específica
- States isolados por camada
- Dependências explícitas via `terraform_remote_state`

### 2. Escalabilidade
- Infraestrutura preparada para crescimento
- Auto-scaling configurado (nodes e pods)
- API Gateway para distribuição de carga

### 3. Segurança
- Recursos em subnets privadas
- Acesso controlado via Security Groups
- Criptografia de dados em trânsito e repouso
- IAM roles com least privilege

### 4. Alta Disponibilidade
- Multi-AZ deployment
- Redundância de componentes críticos
- Health checks e auto-recovery

## 🏛️ Arquitetura de Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                     0-BOOTSTRAP                             │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  S3 Bucket: soat-fast-food-terraform-states          │  │
│  │  - Versionamento habilitado                          │  │
│  │  - Criptografia AES256                               │  │
│  │  - Lifecycle: 90 dias                                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    1-NETWORKING                             │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VPC: 10.0.0.0/16                                    │  │
│  │                                                      │  │
│  │  ┌────────────────┐      ┌────────────────┐        │  │
│  │  │  us-east-1a    │      │  us-east-1b    │        │  │
│  │  │                │      │                │        │  │
│  │  │  Public        │      │  Public        │        │  │
│  │  │  10.0.64/19    │      │  10.0.96/19    │        │  │
│  │  │                │      │                │        │  │
│  │  │  Private       │      │  Private       │        │  │
│  │  │  10.0.0/19     │      │  10.0.32/19    │        │  │
│  │  └────────────────┘      └────────────────┘        │  │
│  │                                                      │  │
│  │  IGW ──┐                          ┌── NAT Gateway   │  │
│  └────────┼──────────────────────────┼─────────────────┘  │
└───────────┼──────────────────────────┼─────────────────────┘
            │                          │
            ▼                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      2-EKS                                  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  EKS Control Plane (Managed by AWS)                  │  │
│  │  - Version: 1.29                                     │  │
│  │  - Endpoint: Public                                  │  │
│  │  - Pod Identity: Enabled                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Node Group                                          │  │
│  │  - Instance Type: t3.medium                          │  │
│  │  - Capacity: 1-2 nodes                               │  │
│  │  - Subnets: Private (Multi-AZ)                       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   3-KUBERNETES                              │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Metrics Server                                      │  │
│  │  - Coleta métricas de CPU/Memory                     │  │
│  │  - Habilita kubectl top                              │  │
│  │  - Suporta HPA                                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Cluster Autoscaler                                  │  │
│  │  - Auto-scaling de nodes                             │  │
│  │  - Pod Identity para IAM                             │  │
│  │  - Auto-discovery do cluster                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  4-API-GATEWAY                              │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  API Gateway HTTP API                                │  │
│  │  - CORS configurado                                  │  │
│  │  - CloudWatch Logs                                   │  │
│  │  - Stage: dev (auto-deploy)                          │  │
│  │                                                      │  │
│  │  [Future: VPC Link para EKS]                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Fluxo de Dados

### 1. Requisição Externa → API Gateway

```
Cliente/Frontend
      │
      ▼
API Gateway (HTTPS)
      │
      ├─→ CloudWatch Logs (Auditoria)
      │
      ▼
[Future: VPC Link]
      │
      ▼
Load Balancer (EKS)
      │
      ▼
Pods (Kubernetes)
```

### 2. Comunicação Interna

```
Pods (Private Subnets)
      │
      ├─→ Internet (via NAT Gateway)
      │
      ├─→ AWS Services (via VPC Endpoints - future)
      │
      └─→ Outros Pods (ClusterIP)
```

## 📊 Componentes Detalhados

### Camada 0: Bootstrap

**Propósito**: Infraestrutura base para Terraform

**Recursos**:
- S3 Bucket para states
- Versionamento e criptografia
- Lifecycle policies

**Características**:
- State local (não usa backend remoto)
- Executado apenas uma vez
- Base para todas as outras camadas

---

### Camada 1: Networking

**Propósito**: Infraestrutura de rede

**Recursos**:
- VPC (10.0.0.0/16)
- 2 Subnets Públicas (Multi-AZ)
- 2 Subnets Privadas (Multi-AZ)
- Internet Gateway
- NAT Gateway
- Route Tables

**Características**:
- Multi-AZ para alta disponibilidade
- Subnets privadas para segurança
- Tags para descoberta do Kubernetes

**Dependências**:
- ✅ 0-bootstrap

---

### Camada 2: EKS

**Propósito**: Cluster Kubernetes gerenciado

**Recursos**:
- EKS Cluster (v1.29)
- Node Group (t3.medium)
- IAM Roles (cluster e nodes)
- Pod Identity Addon

**Características**:
- Control plane gerenciado pela AWS
- Nodes em subnets privadas
- Auto-scaling configurado
- Pod Identity para workloads

**Dependências**:
- ✅ 0-bootstrap
- ✅ 1-networking

---

### Camada 3: Kubernetes

**Propósito**: Add-ons e componentes do Kubernetes

**Recursos**:
- Metrics Server (Helm)
- Cluster Autoscaler (Helm)
- IAM Roles para service accounts

**Características**:
- Metrics para HPA
- Auto-scaling de nodes
- Pod Identity configurado

**Dependências**:
- ✅ 0-bootstrap
- ✅ 2-eks

---

### Camada 4: API Gateway

**Propósito**: Exposição de APIs

**Recursos**:
- API Gateway HTTP API
- CloudWatch Logs
- CORS configurado
- [Future: VPC Link]

**Características**:
- HTTPS por padrão
- Logging estruturado
- Preparado para VPC Link

**Dependências**:
- ✅ 0-bootstrap
- ✅ 1-networking (para VPC Link futuro)

## 🔐 Segurança

### Network Security

```
Internet
    │
    ▼
API Gateway (HTTPS)
    │
    ▼
[VPC Link - Future]
    │
    ▼
Private Subnets
    │
    ├─→ EKS Nodes (Security Groups)
    │
    └─→ NAT Gateway → Internet
```


## 📚 Referências

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Kubernetes Production Best Practices](https://learnk8s.io/production-best-practices)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)