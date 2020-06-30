# Terraform code for Stacklight cloud infrastructure

AWS resources _not_ yet managed by Terraform:
- `rolandcrosby` IAM user
- `terraform` IAM user
- `Provisioning` IAM group
- `rolandcrosby` EC2 key pair

## Structure

- terraform
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
      - Traefik
      - API server
      - Postgres
      - ejabberd
    - pass_secrets.sh: script to source locally before `terraform apply`, to load secrets for this environment from `pass`
- sql: SQL migrations for Flyway to apply to the database
- pass_auth.sh: script to load the approriate AWS keys for this project from `pass`
- docker-hello: example of how to push a container image to an ECR repository

## To do

- Use Swarm services (`docker_service` resource type) instead of plain containers
- Finish setting up Traefik including TLS certificates
- Refactor into modules after determining appropriate boundaries
- Get production set up
- Set up persistent volumes for DB state, set up DB bootstrap script
- set stable versions for docker containers so they don't need to get recreated all the time