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

resource "docker_network" "intranet" {
    name = "intranet"
}

variable "db_password" {
    type = string
}

##################
##### Images #####
##################

data "docker_registry_image" "traefik" {
  name = "traefik:v2.2"
}

resource "docker_image" "traefik" {
  name          = data.docker_registry_image.traefik.name
  pull_triggers = [data.docker_registry_image.traefik.sha256_digest]
}

data "docker_registry_image" "postgres" {
  name = "postgres:12"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
}

data "docker_registry_image" "stacklight_api" {
  name = data.terraform_remote_state.common.outputs.ecr_url_stacklight_api
}

resource "docker_image" "stacklight_api" {
  name          = data.docker_registry_image.stacklight_api.name
  pull_triggers = [data.docker_registry_image.stacklight_api.sha256_digest]
}

data "docker_registry_image" "ejabberd" {
  name = data.terraform_remote_state.common.outputs.ecr_url_ejabberd
}

resource "docker_image" "ejabberd" {
    name = data.docker_registry_image.ejabberd.name
    pull_triggers = [data.docker_registry_image.ejabberd.sha256_digest]
}

data "docker_registry_image" "migrator" {
  name = data.terraform_remote_state.common.outputs.ecr_url_migrator
}

resource "docker_image" "migrator" {
    name = data.docker_registry_image.migrator.name
    pull_triggers = [data.docker_registry_image.migrator.sha256_digest]
}

######################
##### Containers #####
######################

resource "docker_container" "traefik" {
    name = "traefik"
    image = docker_image.traefik.latest
    command = ["--api.insecure=true", "--providers.docker"]
    volumes {
        host_path = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
    }
    networks_advanced {
        name = "bridge"
    }
    networks_advanced {
        name = "intranet"
    }
    ports {
        internal = 80
        external = 80
    }
    ports {
        internal = 443
        external = 443
    }
    ports {
        internal = 8080
        external = 8080
    }
}

resource "docker_container" "stacklight_api" {
    name = "stacklight_api"
    image = docker_image.stacklight_api.latest
    env = [
        "RUST_LOG=debug"
    ]
    networks_advanced {
        name = "intranet"
    }
    labels {
        label = "traefik.http.routers.stacklight_api.middlewares"
        value = "stacklight_api_stripprefix"
    }
    labels {
        label = "traefik.http.middlewares.stacklight_api_stripprefix.stripprefix.prefixes"
        value = "/api/"
    }
    labels {
        label = "traefik.http.routers.stacklight_api.rule"
        value = "Host(`dev.stacklight.im`) && PathPrefix(`/api/`)"
    }
}

resource "docker_container" "ejabberd" {
    name = "ejabberd"
    image = docker_image.ejabberd.latest
    working_dir = "/home/ejabberd" # TODO not sure why omitting this always forces replacement?
    ports {
        internal = 5222
        external = 5222
    }
    networks_advanced {
        name = "intranet"
    }
}

resource "docker_container" "db" {
    name = "db"
    image = docker_image.postgres.latest
    env = [
        "POSTGRES_PASSWORD=${var.db_password}",
        "POSTGRES_HOST_AUTH_METHOD=password"
    ]
    ports {
        internal = 5432
        external = 5432
    }
    networks_advanced {
        name = "intranet"
    }
}