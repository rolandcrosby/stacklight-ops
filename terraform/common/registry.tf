output "ecr_base_url" {
    value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

resource "aws_ecr_repository" "stacklight_api" {
    name = "stacklight_api"
}

output "ecr_url_stacklight_api" {
    value = aws_ecr_repository.stacklight_api.repository_url
}

resource "aws_ecr_repository" "ejabberd" {
    name = "ejabberd"
}

output "ecr_url_ejabberd" {
    value = aws_ecr_repository.ejabberd.repository_url
}

resource "aws_ecr_repository" "migrator" {
    name = "migrator"
}

output "ecr_url_migrator" {
    value = aws_ecr_repository.migrator.repository_url
}

