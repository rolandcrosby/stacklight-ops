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