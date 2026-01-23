terraform {
  backend "s3" {
    bucket  = "soat-fast-food-infra-terraform-states"
    key     = "4-cognito/terraform.tfstate"
    region  = "us-east-1"
  }
}