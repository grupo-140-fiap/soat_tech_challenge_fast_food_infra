# Lambda Function - Auth (dual-purpose: authentication + authorizer)
resource "aws_lambda_function" "auth" {
  function_name = "${var.project_name}-auth-${var.environment}"
  role          = aws_iam_role.lambda_auth.arn

  # Código será uploadado via CI/CD para S3
  s3_bucket = aws_s3_bucket.lambda_packages.id
  s3_key    = "auth/lambda.zip"

  handler = "src/index.handler"
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size

  # VPC Configuration para acessar RDS
  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_auth.id]
  }

  # Environment variables
  environment {
    variables = {
      DB_HOST              = data.terraform_remote_state.db.outputs.rds_endpoint
      DB_PORT              = tostring(data.terraform_remote_state.db.outputs.rds_port)
      DB_NAME              = data.terraform_remote_state.db.outputs.rds_db_name
      DB_USER              = data.terraform_remote_state.db.outputs.rds_username
      DB_PASSWORD          = var.db_password
      COGNITO_USER_POOL_ID = aws_cognito_user_pool.main.id
      COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.lambda_client.id
      AWS_REGION_CUSTOM    = var.aws_region
    }
  }

  # Dependências
  depends_on = [
    aws_cloudwatch_log_group.lambda_auth,
    aws_iam_role_policy_attachment.lambda_vpc_execution,
    aws_iam_role_policy_attachment.lambda_basic_execution
  ]

  tags = {
    Name        = "${var.project_name}-auth-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }

  # Lifecycle para evitar recriação desnecessária
  lifecycle {
    ignore_changes = [
      s3_bucket,
      s3_key,
      source_code_hash
    ]
  }
}

# Lambda Alias para produção (opcional, para versionamento)
resource "aws_lambda_alias" "auth_live" {
  name             = "live"
  description      = "Live alias for auth lambda"
  function_name    = aws_lambda_function.auth.function_name
  function_version = "$LATEST"
}