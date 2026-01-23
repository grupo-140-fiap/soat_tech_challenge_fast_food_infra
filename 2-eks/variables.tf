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

variable "cluster_name" {
  type        = string
  default     = "eks-soat-fast-food-dev"
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  default     = "1.32"
  description = "Kubernetes version for EKS cluster"
}

variable "cluster_log_types" {
  type        = list(string)
  default     = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  description = "EKS control plane log types to enable"
}

variable "endpoint_private_access" {
  type        = bool
  default     = false
  description = "Enable private API server endpoint"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public API server endpoint"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDRs for public API endpoint access"
}

variable "pod_identity_addon_version" {
  type        = string
  default     = "v1.3.8-eksbuild.2"
  description = "Version of the EKS Pod Identity addon"
}

variable "node_group_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "Type of capacity for node group (ON_DEMAND or SPOT)"
}

variable "node_group_instance_types" {
  type        = list(string)
  default     = ["t3.micro"]
  description = "List of instance types for node group"
}

variable "node_group_desired_size" {
  type        = number
  default     = 5
  description = "Desired number of nodes in node group"
}

variable "node_group_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of nodes in node group"
}

variable "node_group_max_size" {
  type        = number
  default     = 6
  description = "Maximum number of nodes in node group"
}
