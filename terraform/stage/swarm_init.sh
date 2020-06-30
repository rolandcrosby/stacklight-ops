#!/bin/bash
# cloud-init script to start a new Docker Swarm cluster
# this runs as root, so sudo is unnecessary
# todo: make a script that joins an existing cluster
# todo: store docker swarm information in tags or something
# todo: pipe the hardcoded ECR url in via a tag or something
set -eux -o pipefail
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add 
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io amazon-ecr-credential-helper
groupadd -f docker
usermod -aG docker ubuntu
systemctl enable docker
docker swarm init
mkdir -p /root/.docker
echo '{"credHelpers": {"823448497702.dkr.ecr.us-east-2.amazonaws.com": "ecr-login"}}' > /root/.docker/config.json