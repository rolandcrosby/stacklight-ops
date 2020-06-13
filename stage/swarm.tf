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

    user_data = <<-EOF
        #!/bin/bash
        set -eux

        sudo apt-get update
        sudo apt-get install -y unzip

        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install

        aws s3 cp "s3://${data.terraform_remote_state.common.outputs.config_bucket_id}/stage/swarm_init.sh" .
        chmod +x ./swarm_init.sh
        sudo ./swarm_init.sh
        EOF
}

resource "aws_security_group" "swarm_host_sg" {
    name = "swarm-host-sg"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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