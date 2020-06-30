#!/bin/bash
set -euxo pipefail

docker build -t "$ECR_REGISTRY/migrator:latest" .
docker push "$ECR_REGISTRY/migrator:latest"