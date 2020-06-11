terraform {
    backend "s3" {
        bucket = "stacklight-terraform-state-20200529"
        key = "stage/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform-locks"
        encrypt = true
    }
}

provider "aws" {
    region = "us-east-2"
}

data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = "stacklight-terraform-state-20200529"
    key = "common/terraform.tfstate"
    region = "us-east-2"
  }
}