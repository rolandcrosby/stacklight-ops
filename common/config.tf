resource "aws_s3_bucket" "config_bucket" {
    bucket = "stacklight-config-20200611"
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_iam_policy" "read_config_bucket" {
    name = "ReadConfigBucket"
    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ListObjectsInBucket",
                "Effect": "Allow",
                "Action": ["s3:ListBucket"],
                "Resource": ["${aws_s3_bucket.config_bucket.arn}"]
            },
            {
                "Sid": "AllObjectActions",
                "Effect": "Allow",
                "Action": "s3:GetObject",
                "Resource": ["${aws_s3_bucket.config_bucket.arn}/*"]
            }
        ]
    }
    EOF
}

output "config_bucket_id" {
    value = aws_s3_bucket.config_bucket.id
}

output "read_config_bucket_policy_arn" {
    value = aws_iam_policy.read_config_bucket.arn
}