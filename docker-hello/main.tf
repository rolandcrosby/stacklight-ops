provider "aws" {
    region = "us-east-2"
}

resource "aws_ecr_repository" "hello_world" {
    name = "hello_world"
}

output "ecr_url" {
    value = aws_ecr_repository.hello_world.repository_url
}