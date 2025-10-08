# 0-Bootstrap - Terraform State Backend

## 📋 Descrição

Esta camada cria a infraestrutura necessária para armazenar os estados do Terraform de forma remota e segura no S3.

## 🎯 Recursos Criados

- **S3 Bucket**: Armazenamento dos arquivos de state do Terraform
  - Versionamento habilitado
  - Criptografia server-side (AES256)
  - Bloqueio de acesso público
  - Lifecycle policy para gerenciar versões antigas (90 dias)

## ⚙️ Configuração

### Variáveis

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `aws_profile` | Perfil AWS CLI | `default` |
| `project_name` | Nome do projeto | `soat-fast-food` |
| `environment` | Ambiente | `dev` |
| `state_bucket_name` | Nome do bucket S3 | `soat-fast-food-terraform-states` |

### Outputs

| Output | Descrição |
|--------|-----------|
| `state_bucket_name` | Nome do bucket S3 |
| `state_bucket_arn` | ARN do bucket S3 |
| `state_bucket_region` | Região do bucket S3 |

## 🚀 Como Usar

### 1. Inicializar Terraform

```bash
cd terraform/0-bootstrap
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

## ⚠️ Importante

- Esta camada **NÃO usa backend remoto** - o state fica local
- Execute esta camada **apenas uma vez** antes das outras
- O bucket criado será usado por todas as outras camadas
- **Não delete** este bucket enquanto houver states de outras camadas

## 🔄 Ordem de Execução

1. ✅ **0-bootstrap** (você está aqui)
2. ⏭️ 1-networking
3. ⏭️ 2-eks
4. ⏭️ 3-kubernetes
5. ⏭️ 5-api-gateway

## 🗑️ Destruição

Para destruir esta camada, **primeiro destrua todas as outras camadas** na ordem reversa:

```bash
# Destruir outras camadas primeiro
cd ../5-api-gateway && terraform destroy
cd ../3-kubernetes && terraform destroy
cd ../2-eks && terraform destroy
cd ../1-networking && terraform destroy

# Então destruir bootstrap
cd ../0-bootstrap && terraform destroy
```

## 📝 Notas

- O bucket S3 tem versionamento habilitado para recuperação de estados anteriores
- Versões antigas são automaticamente deletadas após 90 dias
- Criptografia AES256 é aplicada automaticamente
- Acesso público está completamente bloqueado