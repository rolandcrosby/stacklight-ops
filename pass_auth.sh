# Usage: source pass_auth.sh; terraform apply

export AWS_METADATA_URL="http://metadata.invalid/"
export AWS_ACCESS_KEY_ID="$(pass stacklight-terraform-aws-access-key-id)"
export AWS_SECRET_ACCESS_KEY="$(pass stacklight-terraform-aws-secret-access-key)"
