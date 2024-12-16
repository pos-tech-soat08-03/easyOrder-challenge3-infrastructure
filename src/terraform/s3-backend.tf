# configuração do backend dinamico ******
# considera info do arquivo backend.tfvars
terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key
    region = var.region
  }
}

