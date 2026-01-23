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
  assume_role {
    role_arn = var.aws_profile
  }
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

# Security Group for VPC Link
resource "aws_security_group" "vpc_link" {
  name        = "${var.project_name}-vpc-link-sg"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  # API Gateway VPC Link ENIs need egress to reach NLB in the VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-vpc-link-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# VPC Link
resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.project_name}-vpc-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-vpc-link"
    Environment = var.environment
    Project     = var.project_name
  }
}


# # Resolve the internal NLB created by the Kubernetes Service
# data "aws_lb" "backend" {
#   name = var.nlb_name
# }

# # Fetch the listener on the desired port (typically 80)
# data "aws_lb_listener" "backend" {
#   load_balancer_arn = data.aws_lb.backend.arn
#   port              = var.backend_listener_port
# }

# # Integration via VPC Link to NLB listener
# resource "aws_apigatewayv2_integration" "backend" {
#   api_id                  = aws_apigatewayv2_api.main.id
#   integration_type        = "HTTP_PROXY"
#   integration_method      = "ANY"
#   connection_type         = "VPC_LINK"
#   connection_id           = aws_apigatewayv2_vpc_link.main.id
#   payload_format_version  = "1.0"
#   integration_uri         = data.aws_lb_listener.backend.arn

#   timeout_milliseconds = 29000

#   # Ensure the full client path is forwarded to the backend
#   request_parameters = {
#     "overwrite:path" = "$request.path"
#   }
# }

# Lambda Authorizer
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = data.terraform_remote_state.cognito.outputs.lambda_auth_invoke_arn
  name             = "cognito-authorizer"
  
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = false
  
  authorizer_result_ttl_in_seconds = 300 # Cache 5 min
  
  identity_sources = ["$request.header.Authorization"]
}

# Lambda permission for authorizer
resource "aws_lambda_permission" "authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.cognito.outputs.lambda_auth_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.cognito.id}"
}

# Integration for /auth endpoint
resource "aws_apigatewayv2_integration" "auth" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  
  integration_uri    = data.terraform_remote_state.cognito.outputs.lambda_auth_invoke_arn
  integration_method = "POST"
  
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

# Lambda permission for auth endpoint
resource "aws_lambda_permission" "auth_endpoint" {
  statement_id  = "AllowAPIGatewayInvokeAuth"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.cognito.outputs.lambda_auth_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/auth"
}

# Public route: POST /auth
resource "aws_apigatewayv2_route" "auth" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth.id}"
  
  # No authorizer - public route
}

# # Public route: GET /customers/{cpf}
# resource "aws_apigatewayv2_route" "get_customer_cpf" {
#   api_id    = aws_apigatewayv2_api.main.id
#   route_key = "GET /customers/{cpf}"
#   target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
  
#   # No authorizer - public route
# }

# Protected route: All other routes
# resource "aws_apigatewayv2_route" "proxy" {
#   api_id    = aws_apigatewayv2_api.main.id
#   route_key = var.route_key
#   target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
  
#   # With authorizer - protected routes
#   authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
#   authorization_type = "CUSTOM"
# }
