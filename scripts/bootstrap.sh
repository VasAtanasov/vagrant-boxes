#!/bin/bash

set -e

DOCKER_COMPOSE_VERSION=1.29.1

if [[ $(id -u) -ne 0 ]]; 
  then echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root...";
  exit 1; 
fi

red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
NC="\033[0m" # No Color

redEcho() {
    echo -e "${red}$1${NC}"
}

greenEcho() {
   echo -e "${green}$1${NC}"
}

yellowEcho() {
    echo -e "${yellow}$1${NC}"
}

blueEcho() {
   echo -e "${blue}$1${NC}"
}

step=1
step() {
    greenEcho "Step $step $1"
    step=$((step+1))
}

function addHosts() {
  step "===== Add hosts ====="
  echo "192.168.99.100 docker.dob.lab docker" >> /etc/hosts
}

function updateAndUpgrade() {
  step "===== Update and upgrade all the things ====="
  sudo apt-get update -y
  # sudo apt-get upgrade -y
}

function setupWelcomeMsg() {
  sudo apt-get -y install cowsay
  version=$(cat /etc/os-release |grep VERSION= | cut -d'=' -f2 | sed 's/"//g')
  sudo echo -e "\necho \"Welcome to Vagrant Ubuntu Server ${version}\" | cowsay\n" >> /home/vagrant/.bashrc
  sudo ln -s /usr/games/cowsay /usr/local/bin/cowsay
}

function setupUfw() {
  step "===== Setting up firewall ====="
  sudo ufw allow 8080/tcp comment 'accept 8080'
  sudo ufw allow 80/tcp comment 'accept Apache'
  sudo ufw allow 443/tcp comment 'accept HTTPS connections'
  sudo ufw allow ssh comment 'accept SSH'
  yes y | sudo ufw enable
}

function cleanDocker() {
  step "===== Clean previouse docker installations ====="
  if [ -x "$(command -v docker)" ]; then
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
  else
      echo "There is no docker installed"
  fi
}

function installBashCompletion() {
  updateAndUpgrade
  yellowEcho "Installing bash completion"
  sudo apt-get install bash-completion
}

function installDocker() {
  step "===== Installing docker ====="
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  yellowEcho "Add Docker repository ..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  yellowEcho "Install Docker ..."
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  yellowEcho "Install Docker Compose"
  sudo curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  installBashCompletion
  yellowEcho "Install command completion for Docker Compose"
  sudo curl \
  -sL "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" \
  -o /etc/bash_completion.d/docker-compose

  yellowEcho "Add docker group and user to docker group ..."

  if grep -q "docker" /etc/group
  then
    yellowEcho "docker group alredy exists"
  else
    sudo groupadd docker
  fi

  blueEcho "Adding Current user ${USER} to docker group"
  sudo usermod -aG docker $USER

  exists=$(grep -c "^vagrant:" /etc/passwd)
  if [ $exists -eq 0 ]; then
    echo "The user vagrant does not exist"
  else
    echo "The user vagrant already exists"
    blueEcho "Adding vagrant user to docker group"
    sudo gpasswd -a vagrant docker
  fi

  echo "Enable and start Docker ..."
  sudo systemctl enable docker
  sudo systemctl start docker
}

function main() {
  addHosts
  updateAndUpgrade
  cleanDocker
  installDocker
  setupWelcomeMsg
}

main