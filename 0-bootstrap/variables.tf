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

variable "state_bucket_name" {
  type        = string
  default     = "soat-fast-food-terraform-states"
  description = "Name of the S3 bucket for Terraform state storage"
}