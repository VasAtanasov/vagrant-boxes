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
  sudo mkdir -p /media/cdrom
  sudo mount /dev/cdrom /media/cdrom
  /media/cdrom/VBoxLinuxAdditions.run
}

function main() {
  yellowEcho '===> Running setup.sh script...'

  greenEcho "===> Add the vagrant user to the sudoers list and allow it to sudo without entering password"
  disableSudoPassword "vagrant"

  upgradeAndInstallPackages
  installVirtualBoxGuestAdditions
}

# Disables the sudo password prompt for a user account by editing /etc/sudoers
# Arguments:
#   Account username
function disableSudoPassword() {
  local username="${1}"
  sudo cp /etc/sudoers /etc/sudoers.bak
  sudo bash -c "echo '${username} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

# Reverts the original /etc/sudoers file before this script is ran
function revertSudoers() {
  sudo cp /etc/sudoers.bak /etc/sudoers
  sudo rm -rf /etc/sudoers.bak
}
