provider "aws" {
  region = var.region
  // required_version = ">=0.14.9" 

   backend "s3" {
       bucket = "bastion-tfstate-bucket"
  //      key    = "[Remote_State_S3_Bucket_Key]"
  //  region = "west-us-2"
   }
}