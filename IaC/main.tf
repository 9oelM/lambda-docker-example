terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
   docker = {
     source  = "kreuzwerker/docker"
     version = ">= 2.8.0"
   }
  }
  backend "s3" {
    profile = "localtf"
    bucket  = "my-iac" # change the bucket name to yours
    key            = "your-stack-name"
    region         = "us-west-2" # change to your region
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2" # you will need to change this to your region
  assume_role {
    role_arn     = "arn:aws:iam::{your-account-id}:role/hello_role"
    session_name = "terraform"
  }
}

# for issuing acm certificate
provider "aws" {
 profile = "default"
 region  = "us-east-1"
 alias   = "default_us_east_1"
 assume_role {
   role_arn     = "arn:aws:iam::{your-account-id}:role/hello_role"
   session_name = "terraform"
 }
}


# you can create this resource in other repository because it's not specific to this project
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "tf-state-locks"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key       = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# you can create this resource in other repository because it's not specific to this project
# resource "aws_s3_bucket" "terraform_backend" {
#   bucket = "tf-backend"
#   acl    = "private"

#   versioning {
#     enabled = true
#   }
# }