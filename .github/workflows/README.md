# Tech Challenge - Sistema de Autoatendimento para Lanchonete

Este projeto é parte do **Tech Challenge - Fase 03**, implementando um sistema completo de controle de pedidos para lanchonete com arquitetura Clean Code, Clean Architecture e infraestrutura Kubernetes.

## 📋 Índice

- [Pipeline](#-pipeline)
- [Pré-requisitos](#-pre-requisitos)
- [Secrets do repositório](#-secrets-do-repositorio)
- [Váriaveis de Ambiente](#-variaveis-de-ambiente)
- [Execução do Pipeline via Github Actions](#-execucaoo-do-pipeline-via-github-actions)


## 🏗️ Pipeline Infra EKS

Pipeline com Github Actions para implementar a infraestrutura em Kubernetes com Terrafom.

## ⚙️ Configuração

### Pré-requisitos

- **Git** - Para clonar o repositório

### Secrets do repositório
```
AWS_ACCESS_KEY_ID=<AWS-User-ID>
AWS_SECRET_ACCESS_KEY=<AWS-User-Access-Key>
```

### Variáveis de Ambiente

Configurar as variáveis de ambiente no pipeline.yml:

```env
env:
  AWS_REGION: <aws-region>
```

### Execução do Pipeline via Github Actions

1. Clone o repositório:
```bash
git clone https://github.com/grupo-140-fiap/soat_tech_challenge_fast_food_infra.git
cd soat_tech_challenge_fast_food_infra
```
2. A criação de uma Pull Request para branch mais inicia execução do pipeline:
- Pull Request aberta executa o terraform validate;
- O merge da Pull Request executa o terraforma plan/apply.