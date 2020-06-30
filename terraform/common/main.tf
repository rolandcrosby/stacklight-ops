terraform {
    backend "s3" {
        bucket = "stacklight-terraform-state-20200529"
        key = "common/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}

provider "aws" {
    region = "us-east-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
    value = data.aws_region.current.name
}