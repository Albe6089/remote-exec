//   backend "s3" {
//     bucket = "bastion-tfstate-bucket"
//   }

  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "env:/common/bastion.tfstate"
    region = var.region
  }
