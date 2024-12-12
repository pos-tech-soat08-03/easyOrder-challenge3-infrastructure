terraform {
  backend "s3" {
    bucket = "terraform-state-easyorder-5457a05cc9784e29b347c29f82dc19cc"
    key    = "easyorder-infra/terraform.tfstate"
    region = "us-east-1"
  }
}