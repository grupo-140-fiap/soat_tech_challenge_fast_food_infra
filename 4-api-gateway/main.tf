terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.13.2"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "API Gateway for ${var.project_name}"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }

  tags = {
    Name        = var.api_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Name        = "${var.api_name}-${var.stage_name}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.api_name}-logs"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group for VPC Link (commented - to be implemented when needed)
# resource "aws_security_group" "vpc_link" {
#   name        = "${var.project_name}-vpc-link-sg"
#   description = "Security group for API Gateway VPC Link"
#   vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = "${var.project_name}-vpc-link-sg"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# VPC Link (commented - to be implemented when needed)
# resource "aws_apigatewayv2_vpc_link" "main" {
#   name               = "${var.project_name}-vpc-link"
#   security_group_ids = [aws_security_group.vpc_link.id]
#   subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
#
#   tags = {
#     Name        = "${var.project_name}-vpc-link"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# Example Integration (commented - to be implemented when backend is ready)
# resource "aws_apigatewayv2_integration" "backend" {
#   api_id             = aws_apigatewayv2_api.main.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "ANY"
#   integration_uri    = "http://backend-service.example.com"
#   connection_type    = "VPC_LINK"
#   connection_id      = aws_apigatewayv2_vpc_link.main.id
# }

# Example Route (commented - to be implemented when integration is ready)
# resource "aws_apigatewayv2_route" "example" {
#   api_id    = aws_apigatewayv2_api.main.id
#   route_key = "GET /api/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
# }