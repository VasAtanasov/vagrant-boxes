#!/bin/bash -eux

get_current_dir() {
  local CURRENT_DIR="${BASH_SOURCE%/*}"
  if [[ ! -d "${CURRENT_DIR}" ]]; then CURRENT_DIR="$PWD"; fi
  echo "${CURRENT_DIR}"
}

disable_sudo_password() {
  local username="${1}"
  sudo cp /etc/sudoers /etc/sudoers.bak
  sudo bash -c "echo '${username} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

CURRENT_DIR=$(get_current_dir)
HOME_DIR=/home/vagrant

main() {
  local username="vagrant"

  echo "===> Add ${username} user to the sudoers list and allow it to sudo without entering password"
  disable_sudo_password ${username}

  echo "===> Adding vagrant public key to ~/.ssh/authorized_keys"
  sudo bash "${CURRENT_DIR}/vagrant.sh"

  echo "===> Installing VirtualBox Guest Additions"
  sudo bash "${CURRENT_DIR}/virtualbox.sh"

  echo "Disable verbose messages on login..."
  echo -n > "${HOME_DIR}/.hushlogin"

  echo "===> Disabling cloud init"
  # This delays boot by *a lot* for no apparent reason...
  sudo touch /etc/cloud/cloud-init.disabled
  sudo systemctl -q mask systemd-networkd-wait-online

  echo "===> Removing setup dir"

  if [[ "$username" != "" ]]; then
    for dir in $HOME_DIR; do
      [ "$dir" = ".ssh" ] && continue
      rm -rf "$dir"
    done
   sudo cp -r /etc/skel $HOME_DIR
   sudo chown -R $username:$username $HOME_DIR
  fi

  ls -ahl $HOME_DIR
}

main