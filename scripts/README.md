# 🛠️ Scripts de Automação - Terraform

## 📋 Visão Geral

Esta pasta contém scripts auxiliares para facilitar o gerenciamento da infraestrutura Terraform.

## 📜 Scripts Disponíveis

### 1. deploy-all.sh

**Propósito**: Deploy completo de todas as camadas em ordem sequencial

**Uso**:
```bash
./terraform/scripts/deploy-all.sh
```

**O que faz**:
1. Deploy da camada 0-bootstrap (S3 bucket)
2. Deploy da camada 1-networking (VPC, subnets, gateways)
3. Deploy da camada 2-eks (cluster EKS e nodes)
4. Configura kubectl automaticamente
5. Verifica cluster
6. Deploy da camada 3-kubernetes (Helm charts)
7. Deploy da camada 4-api-gateway (API Gateway)
8. Exibe informações importantes (URLs, endpoints)

**Tempo estimado**: 25-30 minutos

---

### 2. destroy-all.sh

**Propósito**: Destruição completa de todas as camadas em ordem reversa

**Uso**:
```bash
./terraform/scripts/destroy-all.sh
```

**O que faz**:
1. Solicita confirmação (digite 'yes')
2. Destrói camada 4-api-gateway
3. Destrói camada 3-kubernetes
4. Destrói camada 2-eks
5. Destrói camada 1-networking
6. Destrói camada 0-bootstrap

**⚠️ ATENÇÃO**: Esta ação é irreversível!

**Tempo estimado**: 15-20 minutos

---

### 3. validate-all.sh

**Propósito**: Validação de todas as configurações Terraform

**Uso**:
```bash
./terraform/scripts/validate-all.sh
```

**O que faz**:
1. Verifica formatação do código (`terraform fmt`)
2. Inicializa cada camada (sem backend)
3. Valida sintaxe e configuração (`terraform validate`)
4. Reporta erros ou sucesso

**Tempo estimado**: 2-3 minutos

---

## 🚀 Exemplos de Uso

### Deploy Inicial

```bash
# 1. Validar configurações
./terraform/scripts/validate-all.sh

# 2. Deploy completo
./terraform/scripts/deploy-all.sh
```

### Destruir Infraestrutura

```bash
# Destruir tudo (com confirmação)
./terraform/scripts/destroy-all.sh
```

### Validação Rápida

```bash
# Antes de fazer commit
./terraform/scripts/validate-all.sh
```

## 📊 Saída dos Scripts

### deploy-all.sh

```
🚀 Starting Terraform Infrastructure Deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Deploying Layer: 0-Bootstrap
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ️  Initializing Terraform...
ℹ️  Planning changes...
ℹ️  Applying changes...
✅ Layer 0-Bootstrap deployed successfully!

[... continua para outras camadas ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 🎉 All layers deployed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Important Information:

ℹ️  API Gateway URL:
https://xxxxx.execute-api.us-east-1.amazonaws.com/dev

ℹ️  Cluster Information:
Kubernetes control plane is running at https://xxxxx.eks.amazonaws.com
```

### destroy-all.sh

```
🗑️  Starting Terraform Infrastructure Destruction
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  WARNING: This will destroy ALL infrastructure!
⚠️  This action cannot be undone.

Are you sure you want to continue? (type 'yes' to confirm): yes

⚠️  Destroying Layer: 4-API-Gateway
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[... continua ...]

✅ 🎉 All layers destroyed successfully!
```

### validate-all.sh

```
🔍 Starting Terraform Configuration Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Validating Layer: 0-Bootstrap
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ️  Checking format...
✅ Format check passed
ℹ️  Initializing...
ℹ️  Validating configuration...
Success! The configuration is valid.
✅ Validation passed
✅ Layer 0-Bootstrap validated successfully!

[... continua para outras camadas ...]

✅ 🎉 All layers validated successfully!
```

## ⚙️ Configuração

### Pré-requisitos

Todos os scripts assumem:
- AWS CLI configurado com perfil `default`
- Terraform instalado (~> 1.13.2)
- kubectl instalado
- Permissões adequadas na AWS

### Variáveis de Ambiente

Os scripts usam valores padrão, mas você pode customizar:

```bash
# Exemplo: usar perfil AWS diferente
export AWS_PROFILE=meu-perfil
./terraform/scripts/deploy-all.sh
```


## 📝 Notas Importantes

1. **Ordem de Execução**: Os scripts respeitam a ordem correta de dependências
2. **Idempotência**: Scripts podem ser executados múltiplas vezes
3. **Logs**: Toda saída é colorida para fácil identificação
4. **Confirmação**: destroy-all.sh requer confirmação explícita
5. **Cleanup**: Plan files são automaticamente removidos após uso



## 📚 Referências

- [Terraform CLI](https://www.terraform.io/cli)
- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)