# Security Group para Lambda Auth
resource "aws_security_group" "lambda_auth" {
  name_prefix = "${var.project_name}-lambda-auth-sg-"
  description = "Security group for Lambda Auth function"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  # Egress para RDS (MySQL)
  egress {
    description = "MySQL to RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr]
  }

  # Egress para HTTPS (Cognito API)
  egress {
    description = "HTTPS for Cognito"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress geral (para outros serviços AWS)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-auth-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adicionar regra no Security Group do RDS para aceitar conexões da Lambda
resource "aws_security_group_rule" "rds_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_auth.id
  security_group_id        = data.terraform_remote_state.db.outputs.rds_security_group_id
  description              = "Allow Lambda Auth to access RDS"
}