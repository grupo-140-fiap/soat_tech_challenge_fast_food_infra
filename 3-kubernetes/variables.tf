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