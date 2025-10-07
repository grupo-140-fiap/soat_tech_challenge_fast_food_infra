terraform {
  backend "s3" {
    bucket  = "soat-fast-food-terraform-states"
    key     = "5-cognito/terraform.tfstate"
    region  = "us-east-1"
  }
}