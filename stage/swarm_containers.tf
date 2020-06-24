provider "docker" {
    host = "ssh://dev.stacklight.im:22"
    registry_auth {
        address = data.terraform_remote_state.common.outputs.ecr_base_url
        config_file_content = jsonencode({
            "auths" = {
                "https://${data.terraform_remote_state.common.outputs.ecr_base_url}" = {
                    "auth": "",
                    "email": ""
                }
            }
            "credsStore" = "ecr-login"
        })
    }
}

variable "db_password" {
    type = string
}

resource "docker_image" "hello_world" {
    name = "${data.terraform_remote_state.common.outputs.ecr_base_url}/hello_world:latest"
}
