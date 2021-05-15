#!/bin/bash -eux

get_current_dir() {
  local current_dir="${BASH_SOURCE%/*}"
  if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
  echo "${current_dir}"
}

current_dir=$(get_current_dir)

main() {
  echo "===> Installing VirtualBox Guest Additions"
  sudo bash "${current_dir}/virtualbox.sh"

  echo "Disable verbose messages on login..."
  echo -n > "${HOME}/.hushlogin"

  echo "===> Removing setup dir"

  if [[ "$username" != "" ]]; then
   sudo rm -rf /home/$username
   sudo cp -r /etc/skel /home/$username
   sudo chown -R $username:$username /home/$username
  fi

  ls -ahl /home/$username

  echo "===> Adding vagrant public key to ~/.ssh/authorized_keys"
  sudo bash "${current_dir}/vagrant.sh"
}

main