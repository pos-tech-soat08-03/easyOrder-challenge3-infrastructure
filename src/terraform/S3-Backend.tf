terraform {
  backend "s3" {
    bucket = var.backendBucketVoclabs
    key    = "easyorder-infra/terraform.tfstate"
    region = "us-east-1"
  }
}