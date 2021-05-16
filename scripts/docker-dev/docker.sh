#!/bin/bash

set -e

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

update_packages() {
  sudo apt-get update -qq >/dev/null
}

if [[ $(id -u) -ne 0 ]]; then
  echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root..."
  exit 1
fi

if command_exists docker; then
  echo "Removing previouse versions of docker"
  sudo apt-get remove -y docker docker-engine docker.io containerd runc
  sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
else
  echo "There is no docker installed"
fi

install_bash_completion() {
  update_packages
  echo "Installing bash completion"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bash-completion >/dev/null
}

pre_reqs="apt-transport-https ca-certificates curl gnupg lsb-release"

echo "Updateing the apt package index and install packages to allow apt to use a repository over HTTPS"

update_packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $pre_reqs >/dev/null

echo "Adding Docker’s official GPG key"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "Installing Docker Engine"

DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-1.29.1}

update_packages

sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null

echo "Installing Docker Compose"

sudo curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

install_bash_completion

echo "Install command completion for Docker Compose"

sudo curl \
  -sL "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" \
  -o /etc/bash_completion.d/docker-compose
