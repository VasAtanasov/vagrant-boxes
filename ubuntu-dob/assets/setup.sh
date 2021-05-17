#!/bin/bash -eux

if [[ "$(id -u)" != "$(id -u vagrant)" ]]; then
    echo "The provisioning script must be run as the \"vagrant\" user!" >&2
    exit 1
fi

red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
NC="\033[0m" # No Color

red_echo() {
  echo -e "${red}$1${NC}"
}

green_echo() {
  echo -e "${green}$1${NC}"
}

yellow_echo() {
  echo -e "${yellow}$1${NC}"
}

blue_echo() {
  echo -e "${blue}$1${NC}"
}

setup_ufw() {
  sudo ufw allow OpenSSH
  yes y | sudo ufw enable
}

disable_sudo_password() {
  local username="${1}"
  sudo cp /etc/sudoers /etc/sudoers.bak
  sudo bash -c "echo '${username} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

main() {
  yellow_echo '===> Running setup.sh script...'

  local username="vagrant"
  local password="vagrant"

  green_echo "===> Add ${username} user to the sudoers list and allow it to sudo without entering password"
  disable_sudo_password ${username}

  yellow_echo "===> Update and upgrade all the things"
  green_echo "===> Update the package list"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
  green_echo "===> Upgrade all installed packages"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

  green_echo "===> Installing packages"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
    pv tree vim curl zip unzip 

  green_echo "===> Minimize the number of running daemons..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge snapd
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove

  green_echo "===> Disabling cloud init"
  # This delays boot by *a lot* for no apparent reason...
  sudo touch /etc/cloud/cloud-init.disabled
  sudo systemctl -q mask systemd-networkd-wait-online

  green_echo "===> Disable verbose messages on login..."
  echo -n > "${HOME}/.hushlogin"

  green_echo "===> Disabling unattended-upgrades"
  # We don't want the system to change behind our backs...
  sudo systemctl -q is-active unattended-upgrades && sudo systemctl stop unattended-upgrades
  sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge unattended-upgrades

  # green_echo "===> Setting up firewall"
  # setup_ufw

  yellow_echo "===> setup.sh Done!"
}

main
