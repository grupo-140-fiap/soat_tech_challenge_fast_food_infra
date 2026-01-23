variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "aws_profile" {
  type        = string
  default     = "arn:aws:iam::426315020032:role/soat-tech-challenge-fast-food-role"
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

variable "metrics_server_version" {
  type        = string
  default     = "3.12.1"
  description = "Version of metrics-server Helm chart"
}

variable "cluster_autoscaler_version" {
  type        = string
  default     = "9.37.0"
  description = "Version of cluster-autoscaler Helm chart"
}

# EKS Access Entries (grant cluster access to an IAM principal)
variable "eks_access_user_arn" {
  type        = string
  default     = "arn:aws:iam::323726447562:root"
  description = "IAM user or role ARN to grant EKS access (leave empty to disable)"
}

variable "eks_access_policy_name" {
  type        = string
  default     = "AmazonEKSAdminPolicy"
  description = "EKS access policy name to associate (e.g., AmazonEKSAdminPolicy)"
}
