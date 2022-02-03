terraform {
  backend "s3" {
    bucket = var.bucket
    key    = "env:/common/bastion.tfstate"
    region = var.region
  }
}

