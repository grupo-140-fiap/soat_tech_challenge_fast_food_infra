terraform {
  backend "s3" {
    bucket  = "soat-fast-food-terraform-states"
    key     = "2-eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}