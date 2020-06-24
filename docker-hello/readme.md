# Docker hello-world for ECR

How do you actually push something to ECR? Here is a minimal demo:

- Create ECR repository (in this directory, `terraform init && terraform apply`)
- Note domain of ECR registry from Terraform output, henceforth `<ECR DOMAIN>`: `<ACCOUNT ID>.dkr.ecr.<REGION>.amazonaws.com`
- Install ECR credential helper: `sudo apt update && sudo apt install amazon-ecr-credential-helper`
- Configure credential helper - put this in ~/.docker/config.json:

```
{
    "credHelpers": {
        "<ECR DOMAIN>": "ecr-login"
    }
}
```
- Build your Docker image: `docker build --tag <ECR DOMAIN>/hello_world:latest .`
- Push it to the repository: `docker push <ECR DOMAIN>/hello_world:latest`