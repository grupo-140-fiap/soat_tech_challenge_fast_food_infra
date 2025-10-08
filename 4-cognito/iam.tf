# IAM Role para Lambda Auth
resource "aws_iam_role" "lambda_auth" {
  name = "${var.project_name}-lambda-auth-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-auth-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy para VPC (ENI management)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Policy para CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom Policy para Cognito
resource "aws_iam_role_policy" "lambda_cognito" {
  name = "${var.project_name}-lambda-cognito-policy-${var.environment}"
  role = aws_iam_role.lambda_auth.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminGetUser",
          "cognito-idp:ListUsers"
        ]
        Resource = aws_cognito_user_pool.main.arn
      }
    ]
  })
}

# Custom Policy para acessar Secrets Manager (DB password)
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.project_name}-lambda-secrets-policy-${var.environment}"
  role = aws_iam_role.lambda_auth.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Log Group para Lambda
resource "aws_cloudwatch_log_group" "lambda_auth" {
  name              = "/aws/lambda/${var.project_name}-auth-${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-lambda-auth-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}