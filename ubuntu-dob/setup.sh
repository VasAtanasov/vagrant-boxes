#!/bin/bash

set -e

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

function upgradeAndInstallPackages() {
  yellowEcho "===> Upgrading and installing packages"
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install -y build-essential dkms linux-headers-$(uname -r) gcc make tar bzip2 wget curl git
}

function installVirtualBoxGuestAdditions() {
  yellowEcho "===> Installing VirtualBox Guest Additions"
  sudo mount /dev/sr0 /mnt
  sudo /mnt/VBoxLinuxAdditions.run
}

function main() {
  yellowEcho '===> Running setup.sh script...'

  greenEcho "===> Add the vagrant user to the sudoers list and allow it to sudo without entering password"
  disableSudoPassword "vagrant"

  upgradeAndInstallPackages

  greenEcho "===> Add the vagrant user to the vboxsf group"
  sudo usermod -aG vboxsf vagrant
  addVagrantSSHKey "vagrant"

  greenEcho "===> Cleaning up apt-get cache"
  cleanUp

  sudo dd if=/dev/zero of=/EMPTY bs=1M status=progress
  sudo rm -f /EMPTY
}

function addVagrantSSHKey() {
  yellowEcho "===> Adding public ssh key"
  local username=${1}
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  wget --no-check-certificate \
    https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
    -O ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
}

function disableSudoPassword() {
  local username="${1}"
  sudo cp /etc/sudoers /etc/sudoers.bak
  sudo bash -c "echo '${username} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

function revertSudoers() {
  sudo cp /etc/sudoers.bak /etc/sudoers
  sudo rm -rf /etc/sudoers.bak
}

function setupUfw() {
  sudo ufw allow OpenSSH
  yes y | sudo ufw enable
}

function cleanUp() {
  sudo apt-get autoremove
  sudo rm -rf ~/.cache/thumbnails/*
  sudo apt-get clean
}

main
installVirtualBoxGuestAdditions