resource "aws_s3_bucket_object" "swarm_init_script" {
    key = "stage/swarm_init.sh"
    bucket = data.terraform_remote_state.common.outputs.config_bucket_id
    source = "swarm_init.sh"
    etag = filemd5("swarm_init.sh")
}

resource "aws_iam_role" "swarm_host_role" {
    name = "SwarmHostRole"
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "swarm_host_read_config_bucket" {
    role = aws_iam_role.swarm_host_role.name
    policy_arn = data.terraform_remote_state.common.outputs.read_config_bucket_policy_arn
}

resource "aws_iam_role_policy_attachment" "swarm_host_read_ecr" {
    role = aws_iam_role.swarm_host_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "swarm_host_profile" {
    name = "swarm_host_profile"
    role = aws_iam_role.swarm_host_role.name
}

resource "aws_eip" "swarm_public_ip" {
    instance = aws_instance.swarm_host.id
}

resource "aws_instance" "swarm_host" {
    instance_type = "t2.micro"
    ami = "ami-013de1b045799b282"
    key_name = "rolandcrosby"
    vpc_security_group_ids = [aws_security_group.swarm_host_sg.id]
    iam_instance_profile = aws_iam_instance_profile.swarm_host_profile.id

    user_data = templatefile(
        "./swarm_bootstrap.sh.tmpl",
        { bucket_id = data.terraform_remote_state.common.outputs.config_bucket_id }
    )
}

variable "client_ip" {
    type = string
}

resource "aws_security_group" "swarm_host_sg" {
    name = "swarm-host-sg"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["${var.client_ip}/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "swarm_public_ip" {
    value = aws_eip.swarm_public_ip.public_ip
}