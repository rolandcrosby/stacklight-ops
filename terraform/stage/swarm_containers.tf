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
    driver = "overlay"
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

####################
##### Services #####
####################

resource "docker_service" "traefik" {
    name = "traefik-service"

    task_spec {
        container_spec {
            image = docker_image.traefik.latest
            args = [
                "--api.insecure=true",
                "--providers.docker",
                "--providers.docker.swarmMode=true",
                "--log.level=debug",
                "--entryPoints.web.address=:80",
                "--entryPoints.websecure.address=:443",
                "--entryPoints.xmpp.address=:5222"
            ]
            mounts {
                target = "/var/run/docker.sock"
                source = "/var/run/docker.sock"
                type = "bind"
            }
        }
        placement {
            constraints = ["node.role==manager"]
        }
        networks = [docker_network.intranet.id]
    }
    endpoint_spec {
        ports {
            published_port = 80
            target_port = 80
        }
        ports {
            published_port = 443
            target_port = 443
        }
        ports {
            published_port = 5222
            target_port = 5222
        }
        ports {
            published_port = 8080
            target_port = 8080
        }
    }
    labels {
        label = "traefik.enable"
        value = "false"
    }
}

resource "docker_service" "stacklight_api" {
    name = "stacklight-api"

    task_spec {
        container_spec {
            image = docker_image.stacklight_api.latest
            env = {
                RUST_LOG = "debug"
            }
        }
        networks = [docker_network.intranet.id]
    }

    labels {
        label = "traefik.http.routers.stacklight_api.rule"
        value = "Host(`dev.stacklight.im`) && PathPrefix(`/api/`)"
    }
    labels {
        label = "traefik.http.services.stacklight_api.loadbalancer.server.port"
        value = "8000"
    }
    labels {
        label = "traefik.http.routers.stacklight_api.entrypoints"
        value = "web,websecure"
    }
    labels {
        label = "traefik.http.routers.stacklight_api.middlewares"
        value = "stacklight_api_stripprefix"
    }
    labels {
        label = "traefik.http.middlewares.stacklight_api_stripprefix.stripprefix.prefixes"
        value = "/api/"
    }
}

resource "docker_service" "ejabberd" {
    name = "ejabberd"
    task_spec {
        container_spec {
            image = docker_image.ejabberd.latest
            dir = "/home/ejabberd"
        }
        networks = [docker_network.intranet.id]
    }
    labels {
        label = "traefik.tcp.services.ejabberd.loadbalancer.server.port"
        value = "5222"
    }
    labels {
        label = "traefik.tcp.routers.ejrouter.service"
        value = "ejabberd"
    }
    labels {
        label = "traefik.tcp.routers.ejrouter.entrypoints"
        value = "xmpp"
    }
    labels {
        label = "traefik.tcp.routers.ejrouter.rule"
        value = "HostSNI(`*`)"
    }
}
resource "docker_service" "db" {
    name = "db"
    task_spec {
        container_spec {
            image = docker_image.postgres.latest
            env = {
                POSTGRES_PASSWORD = var.db_password,
                POSTGRES_HOST_AUTH_METHOD = "password"
            }
        }
        networks = [docker_network.intranet.id]
    }
}
