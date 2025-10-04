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

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "availability_zone_1" {
  type        = string
  default     = "us-east-1a"
  description = "First availability zone"
}

variable "availability_zone_2" {
  type        = string
  default     = "us-east-1b"
  description = "Second availability zone"
}

variable "private_subnet_zone_1_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR block for private subnet in zone 1"
}

variable "private_subnet_zone_2_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for private subnet in zone 2"
}

variable "public_subnet_zone_1_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for public subnet in zone 1"
}

variable "public_subnet_zone_2_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR block for public subnet in zone 2"
}

variable "eks_cluster_name" {
  type        = string
  default     = "eks-soat-fast-food-dev"
  description = "EKS cluster name for subnet tagging"
}
