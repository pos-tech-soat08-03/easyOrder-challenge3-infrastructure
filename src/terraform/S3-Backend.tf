terraform {
  backend "s3" {
    bucket = "terraform-state-easyorder"
    key    = "easyorder-infra/terraform.tfstate"
    region = "us-east-1"
  }
}

