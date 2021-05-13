#!/bin/bash -eux

function getCurrentDir() {
  local current_dir="${BASH_SOURCE%/*}"
  if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
  echo "${current_dir}"
}

function includeDependencies() {
  source "${current_dir}/functions.sh"
  source "${current_dir}/echolib.sh"
}

export HOME_DIR=/home/vagrant
export DEBIAN_FRONTEND=noninteractive

current_dir=$(getCurrentDir)
includeDependencies

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

  update

  greenEcho "===> Add ${username} user to the sudoers list and allow it to sudo without entering password"
  disableSudoPassword ${username}

  greenEcho "===> Adding vagrant public key to ~/.ssh/authorized_keys"
  sudo bash "${current_dir}/vagrant.sh"

  greenEcho "===> Installing VirtualBox Guest Additions"
  sudo bash "${current_dir}/virtualbox.sh"

  greenEcho "===> Cleaning up"
  sudo bash "${current_dir}/cleanup.sh"

  greenEcho "===> Optimizing space"
  sudo bash "${current_dir}/minimize.sh"

  greenEcho "===> Setting up firewall"
  setupUfw
}

main
