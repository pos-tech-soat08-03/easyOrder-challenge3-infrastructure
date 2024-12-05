terraform {
  backend "s3" {
    bucket = "terraform-state-easyorder"
    key    = "Prod/terraform.tfstate"
    region = "us-east-1"
  }
}