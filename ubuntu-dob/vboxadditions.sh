#!/bin/bash

function installVirtualBoxGuestAdditions() {
  echo "===> Installing VirtualBox Guest Additions"

  local FOLDER=/media/cdrom

  if [[ -d "FOLDER" ]]; then
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
  local vbGroup="vboxsf"

  installVirtualBoxGuestAdditions
  echo "===> Adding ${username} user to the ${vbGroup} group"

  if grep -q $vbGroup /etc/group; then
    sudo usermod -aG ${vbGroup} ${username}
  else
    echo "Group ${vbGroup} does not exist"
  fi
}

main