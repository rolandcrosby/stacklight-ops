resource "aws_ecr_repository" "main" {
    name = "stacklight_container_images"
}

output "container_repository_url" {
    value = aws_ecr_repository.main.repository_url
}

