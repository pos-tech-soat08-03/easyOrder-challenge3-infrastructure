terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
}

module "cognito" {
    source = "./resources/cognito"
}



#module "api-gateway" {
#    source = "./resources/api-gateway"
#}
