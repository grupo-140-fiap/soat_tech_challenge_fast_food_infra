output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_apigatewayv2_api.main.arn
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.id
}

output "stage_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_apigatewayv2_stage.main.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway.arn
}

output "authorizer_id" {
  description = "ID of the Cognito authorizer"
  value       = aws_apigatewayv2_authorizer.cognito.id
}

output "auth_route_id" {
  description = "ID of the /auth route"
  value       = aws_apigatewayv2_route.auth.id
}

output "customer_cpf_route_id" {
  description = "ID of the /customers/{cpf} route"
  value       = aws_apigatewayv2_route.get_customer_cpf.id
}

output "protected_route_id" {
  description = "ID of the protected proxy route"
  value       = aws_apigatewayv2_route.proxy.id
}