provider "docker" {
    host = "ssh://dev.stacklight.im:22"
}

variable "db_password" {
    type = string
}
