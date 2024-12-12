variable "bucket" {
  description = "The S3 bucket to store the Terraform state file"
  default = "terraform-state-easyorder"
}
variable "key" {
  description = "The S3 key to store the Terraform state file"
  default = "easyorder-infra/terraform.tfstate"
}
variable "region" {
  description = "The S3 region to store the Terraform state file"
  default = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "${var.bucket}"
    key    = "${var.key}"
    region = "${var.region}"
  }
}

