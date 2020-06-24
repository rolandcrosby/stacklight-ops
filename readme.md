# Terraform code for Stacklight cloud infrastructure

AWS resources _not_ yet managed by Terraform:
- `rolandcrosby` IAM user
- `terraform` IAM user
- `Provisioning` IAM group
- `rolandcrosby` EC2 key pair

## Structure

- common
  - main.tf: backend and provider configuration
  - config.tf: S3 bucket to store configuration files like cloud-init scripts
  - dns.tf: DNS zones for the root `stacklight.app` and `stacklight.im` domains
  - registry.tf: ECR registry data and repositories for Docker images
  - terraform_state.tf: S3 bucket and DynamoDB table to manage Terraform state
- stage
  - main.tf: backend and provider configuration
  - dns.tf: DNS records for staging services
  - swarm_machine.tf: EC2 node that runs Docker Swarm
    - swarm_init.sh: script that sets up Docker Swarm (retrieved from S3 by swarm node)
  - swarm_containers.tf: Docker containers that run on the Swarm EC2 node
  - pass_secrets.sh: script to source locally before `terraform apply`, to load secrets for this environment from `pass`
- pass_auth.sh: script to load the approriate AWS keys for this project from `pass`
- docker-hello: example of how to push a container image to an ECR repository