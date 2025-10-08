# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "cognito_client_id" {
  description = "ID of the Cognito App Client"
  value       = aws_cognito_user_pool_client.lambda_client.id
}

output "cognito_domain" {
  description = "Cognito User Pool Domain"
  value       = aws_cognito_user_pool_domain.main.domain
}

# Lambda Outputs
output "lambda_auth_function_name" {
  description = "Name of the Lambda Auth function"
  value       = aws_lambda_function.auth.function_name
}

output "lambda_auth_function_arn" {
  description = "ARN of the Lambda Auth function"
  value       = aws_lambda_function.auth.arn
}

output "lambda_auth_invoke_arn" {
  description = "Invoke ARN of the Lambda Auth function"
  value       = aws_lambda_function.auth.invoke_arn
}

output "lambda_auth_qualified_arn" {
  description = "Qualified ARN of the Lambda Auth function"
  value       = aws_lambda_function.auth.qualified_arn
}

output "lambda_auth_alias_arn" {
  description = "ARN of the Lambda Auth alias"
  value       = aws_lambda_alias.auth_live.arn
}

# S3 Outputs
output "lambda_packages_bucket_name" {
  description = "Name of the S3 bucket for Lambda packages"
  value       = aws_s3_bucket.lambda_packages.id
}

output "lambda_packages_bucket_arn" {
  description = "ARN of the S3 bucket for Lambda packages"
  value       = aws_s3_bucket.lambda_packages.arn
}

# Security Group Outputs
output "lambda_auth_security_group_id" {
  description = "ID of the Lambda Auth security group"
  value       = aws_security_group.lambda_auth.id
}

# CloudWatch Outputs
output "lambda_auth_log_group_name" {
  description = "Name of the Lambda Auth CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_auth.name
}