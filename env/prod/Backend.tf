terraform {
  backend "s3" {
    bucket = var.bucket
    key    = "easyorder-eks/terraform.tfstate"
    region = "us-east-1"
  }
}