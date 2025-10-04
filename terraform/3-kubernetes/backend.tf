terraform {
  backend "s3" {
    bucket  = "soat-fast-food-terraform-states"
    key     = "3-kubernetes/terraform.tfstate"
    region  = "us-east-1"
    profile = "elvismariel"
    encrypt = true
  }
}