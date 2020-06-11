# Terraform code for Stacklight cloud infrastructure

AWS resources _not_ yet managed by Terraform:
- `rolandcrosby` IAM user
- `terraform` IAM user
- `Provisioning` IAM group
- `rolandcrosby` EC2 key pair

## Structure

- common
  - terraform_state.tf: S3 bucket and DynamoDB table to manage Terraform state
  - config.tf: S3 bucket to store configuration files like cloud-init scripts
  - dns.tf: DNS zones for the root `stacklight.app` and `stacklight.im` domains
- stage
  - dns.tf: DNS records for staging services
  - swarm.tf: EC2 node that runs Docker Swarm
  - swarm_init.sh: script that sets up Docker Swarm (retrieved from S3 by swarm node)