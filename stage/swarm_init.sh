#!/bin/bash
# cloud-init script to start a new Docker Swarm cluster
# todo: make a script that joins an existing cluster
# todo: store docker swarm information in tags or something
set -eux -o pipefail
apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add 
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo docker swarm init
