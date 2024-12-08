terraform {
  backend "s3" {
    bucket = "terraform-state-easyorder"
    key    = "easyorder-eks/terraform.tfstate"
    region = "us-east-1"
  }
}