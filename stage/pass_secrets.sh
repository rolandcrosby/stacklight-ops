# Fetches secrets for the `stage` environment from `pass`.
# Usage: source pass_secrets.sh; terraform apply

export TF_VAR_db_password="$(pass db-password)"
