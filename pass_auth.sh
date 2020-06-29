# Usage: source pass_auth.sh; terraform apply

export TF_PROJECT=stacklight
export AWS_METADATA_URL="http://metadata.invalid/"
export AWS_ACCESS_KEY_ID="$(pass stacklight-terraform-aws-access-key-id)"
export AWS_SECRET_ACCESS_KEY="$(pass stacklight-terraform-aws-secret-access-key)"
export ECR_REGISTRY=823448497702.dkr.ecr.us-east-2.amazonaws.com
export TF_VAR_client_ip=$(echo $SSH_CLIENT | cut -d ' '  -f 1)