//   backend "s3" {
//     bucket = "bastion-tfstate-bucket"
//   }


data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "env:/common/bastion.tfstate"
    region = var.region
  }
}