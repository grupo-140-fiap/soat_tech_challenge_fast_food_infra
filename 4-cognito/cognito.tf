terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.13.2"
}

provider "aws" {
  region  = var.aws_region
  assume_role {
    role_arn = var.aws_profile
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-users-${var.environment}"

  # Custom attributes para armazenar referência do cliente no RDS
  schema {
    name                = "customer_id"
    attribute_data_type = "Number"
    mutable             = true
    
    number_attribute_constraints {
      min_value = 1
    }
  }

  schema {
    name                = "cpf"
    attribute_data_type = "String"
    mutable             = false
    
    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  # Email como atributo padrão (required)
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    
    string_attribute_constraints {
      min_length = 5
      max_length = 100
    }
  }

  # Configuração de senha (relaxada pois auth é por CPF)
  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  # Sem verificação automática (auth por CPF)
  auto_verified_attributes = []

  # Configuração de email (opcional, para notificações futuras)
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Username configuration - usar email como username
  username_attributes = ["email"]

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  # Lifecycle
  deletion_protection = "ACTIVE"

  tags = {
    Name        = "${var.project_name}-user-pool-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# App Client para Lambda (sem secret)
resource "aws_cognito_user_pool_client" "lambda_client" {
  name         = "${var.project_name}-lambda-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  # Não gerar secret (Lambda usa IAM)
  generate_secret = false

  # Flows permitidos para admin auth
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  # Token validity
  refresh_token_validity = 30 # 30 dias
  access_token_validity  = 60 # 60 minutos
  id_token_validity      = 60 # 60 minutos

  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read/Write attributes
  read_attributes = [
    "email",
    "custom:customer_id",
    "custom:cpf"
  ]

  write_attributes = [
    "email"
  ]
}

# User Pool Domain (para hosted UI - opcional)
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}