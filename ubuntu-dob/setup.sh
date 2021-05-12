#!/bin/bash

function getCurrentDir() {
  local current_dir="${BASH_SOURCE%/*}"
  if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
  echo "${current_dir}"
}

function includeDependencies() {
  source "${current_dir}/functions.sh"
  source "${current_dir}/echolib.sh"
}

current_dir=$(getCurrentDir)
includeDependencies

function upgradeAndInstallPackages() {
  yellowEcho "===> Upgrading and installing packages"
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install -y build-essential dkms linux-headers-"$(uname -r)" gcc make tar bzip2 wget curl git
}

function cleanUpCache() {
  sudo apt-get autoremove
  sudo rm -rf ~/.cache/thumbnails/*
  sudo apt-get clean
}

function main() {
  yellowEcho '===> Running setup.sh script...'

  greenEcho "===> Checking if vagrant user exists"
  local username="vagrant"
  local password="vagrant"

  local exists
  exists=$(grep -c "^${username}:" /etc/passwd)
  if [ "$exists" -eq 0 ]; then
    redEcho "===> User ${username} does not exist"
    greenEcho "===> Attempting to create ${username} user"
    addUserAccount ${username} ${password}
  else
    greenEcho "===> User ${username} already exists ..."
  fi

  greenEcho "===> Add ${username} user to the sudoers list and allow it to sudo without entering password"
  disableSudoPassword ${username}

  upgradeAndInstallPackages

  greenEcho "===> Adding vagrant public key to ~/.ssh/authorized_keys"
  wget --no-check-certificate -q https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
  addSSHKey ${username} "$(cat vagrant.pub)"
  rm vagrant.pub

  greenEcho "===> Cleaning cache"
  cleanUpCache

  greenEcho "===> Optimizing space"
  zero

  setupUfw
}

function zero() {
  sudo dd if=/dev/zero of=/EMPTY bs=1M status=progress
  sudo rm -rf /EMPTY
}

main
