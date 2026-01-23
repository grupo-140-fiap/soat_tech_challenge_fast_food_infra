terraform {
  backend "s3" {
    bucket  = "soat-fast-food-infra-terraform-states"
    key     = "5-api-gateway/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}