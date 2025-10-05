variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "aws_profile" {
  type        = string
  default     = "default"
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

variable "api_name" {
  type        = string
  default     = "soat-fast-food-api"
  description = "Name of the API Gateway"
}

variable "stage_name" {
  type        = string
  default     = "dev"
  description = "Name of the API Gateway stage"
}

variable "auto_deploy" {
  type        = bool
  default     = true
  description = "Enable auto-deployment for the stage"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain API Gateway logs"
}

variable "cors_allow_origins" {
  type        = list(string)
  default     = ["*"]
  description = "List of allowed origins for CORS"
}

variable "cors_allow_methods" {
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  description = "List of allowed HTTP methods for CORS"
}

variable "cors_allow_headers" {
  type        = list(string)
  default     = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
  description = "List of allowed headers for CORS"
}

variable "cors_max_age" {
  type        = number
  default     = 300
  description = "Maximum age for CORS preflight requests in seconds"
}