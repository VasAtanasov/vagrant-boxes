#!/bin/bash

# Add the new user account
# Arguments:
#   Account Username
#   Account Password
#   Flag to determine if user account is added silently. (With / Without GECOS prompt)
function addUserAccount() {
  local username=${1}
  local password=${2}
  local silent_mode=${3}

  if [[ ${silent_mode} == "true" ]]; then
    sudo adduser --disabled-password --gecos '' "${username}"
  else
    sudo adduser --disabled-password "${username}"
  fi

  echo "${username}:${password}" | sudo chpasswd
  sudo usermod -aG sudo "${username}"
}

# Add the local machine public SSH Key for the new user account
# Arguments:
#   Account Username
#   Public SSH Key
function addSSHKey() {
  local username=${1}
  local sshKey=${2}

  execAsUser "${username}" "mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys"
  execAsUser "${username}" "echo \"${sshKey}\" | sudo tee -a ~/.ssh/authorized_keys"
  execAsUser "${username}" "chmod 600 ~/.ssh/authorized_keys"
}

# Execute a command as a certain user
# Arguments:
#   Account Username
#   Command to be executed
function execAsUser() {
  local username=${1}
  local exec_command=${2}

  sudo -u "${username}" -H bash -c "${exec_command}"
}

# Setup the Uncomplicated Firewall
function setupUfw() {
  sudo ufw allow OpenSSH
  yes y | sudo ufw enable
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
