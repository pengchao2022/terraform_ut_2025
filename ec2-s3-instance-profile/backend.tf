terraform {
  backend "s3" {
    bucket         = "terraformstatefile090909"
    key            = "ec2_s3_terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

}