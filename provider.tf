terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
  required_version = "~> 1.13.2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "eks-${var.project_name}"
}