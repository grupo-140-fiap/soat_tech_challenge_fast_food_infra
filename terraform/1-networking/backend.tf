terraform {
  backend "s3" {
    bucket  = "soat-fast-food-terraform-states"
    key     = "1-networking/terraform.tfstate"
    region  = "us-east-1"
    profile = "elvismariel"
    encrypt = true
  }
}