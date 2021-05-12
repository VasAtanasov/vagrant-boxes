#!/bin/bash

function installVirtualBoxGuestAdditions() {
  echo "===> Installing VirtualBox Guest Additions"

  local FOLDER=/media/cdrom

  if [[ -d "FOLDER" ]]
  then
    echo "$FOLDER exists on your filesystem."
  else
    sudo mkdir -p ${FOLDER}
  fi

  if [[ $(findmnt -M "$FOLDER") ]]; then
    echo "Mounted"
  else
      sudo mount /dev/sr0 ${FOLDER}
  fi

  sudo ${FOLDER}/VBoxLinuxAdditions.run
}

function main() {
  local username="vagrant"

  installVirtualBoxGuestAdditions
  echo "===> Adding ${username} user to the vboxsf group"
  sudo usermod -aG vboxsf ${username}

}
