# Get networking layer outputs via remote state
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket  = "soat-fast-food-terraform-states"
    key     = "1-networking/terraform.tfstate"
    region  = "us-east-1"
    profile = var.aws_profile
  }
}