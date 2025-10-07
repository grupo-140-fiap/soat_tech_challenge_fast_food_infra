variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "aws_profile" {
  type        = string
  default     = "arn:aws:iam::323726447562:role/soat-tech-challenge-fast-food-role"
  description = "AWS ARN role to use"
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

variable "nlb_name" {
  type        = string
  default     = "ad51ed2ea764549dc8a78495dfb5e978"
  description = "Name of the internal NLB created by the Kubernetes Service"
}

variable "backend_listener_port" {
  type        = number
  default     = 80
  description = "Listener port on the NLB to route traffic to the backend"
}

variable "route_key" {
  type        = string
  default     = "ANY /{proxy+}"
  description = "API Gateway route key to bind to the backend integration"
}
