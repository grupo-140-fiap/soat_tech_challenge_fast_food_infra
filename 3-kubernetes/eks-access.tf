locals {
  eks_access_policy_arn = "arn:aws:eks::aws:cluster-access-policy/${var.eks_access_policy_name}"
}

# Grant EKS access to an IAM principal via Access Entries
resource "aws_eks_access_entry" "extra_user" {
  count         = var.eks_access_user_arn != "" ? 1 : 0
  cluster_name  = data.terraform_remote_state.eks.outputs.cluster_name
  principal_arn = var.eks_access_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "extra_user" {
  count         = var.eks_access_user_arn != "" ? 1 : 0
  cluster_name  = data.terraform_remote_state.eks.outputs.cluster_name
  principal_arn = var.eks_access_user_arn
  policy_arn    = local.eks_access_policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.extra_user]
}

