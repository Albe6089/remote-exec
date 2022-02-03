terraform {
  backend "s3" {
    bucket = "bastion-buck"
    key    = "env:/common/bastion.tfstate"
    region = "us-west-2"
  }
}

