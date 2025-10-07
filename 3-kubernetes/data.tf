# Get EKS cluster outputs via remote state
data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket  = "soat-fast-food-terraform-states"
    key     = "2-eks/terraform.tfstate"
    region  = "us-east-1"
    profile = var.aws_profile
  }
}

# Get EKS cluster details for provider configuration
data "aws_eks_cluster" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}