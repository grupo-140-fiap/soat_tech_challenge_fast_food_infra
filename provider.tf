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
  region  = "us-east-1"
  profile = "elvismariel"
}