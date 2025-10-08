variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "aws_profile" {
  type        = string
  default     = "arn:aws:iam::323726447562:role/soat-tech-challenge-fast-food-role"
  description = "AWS CLI profile to use"
}

variable "project_name" {
  type        = string
  default     = "soat-fast-food"
  description = "Project name used for resource naming"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "db_password" {
  type        = string
  description = "Database password for Lambda to connect to RDS"
  sensitive   = true
  default     = "FTtWQZrJ6crfvMdPNqnL"
}

variable "lambda_runtime" {
  type        = string
  default     = "nodejs20.x"
  description = "Lambda runtime version"
}

variable "lambda_timeout" {
  type        = number
  default     = 30
  description = "Lambda timeout in seconds"
}

variable "lambda_memory_size" {
  type        = number
  default     = 512
  description = "Lambda memory size in MB"
}