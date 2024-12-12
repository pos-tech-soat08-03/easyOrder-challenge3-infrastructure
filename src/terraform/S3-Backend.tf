terraform {
  backend "s3" {
    bucket = var.bucketStates
    key    = var.keyStates
    region = var.regionDefault
  }
}

