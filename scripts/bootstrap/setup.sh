#!/bin/bash -eux

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
  ufw allow OpenSSH
  yes y | sudo ufw enable
}

disable_sudo_password() {
  local username="${1}"
  cp /etc/sudoers /etc/sudoers.bak
  bash -c "echo '${username} ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
}

main() {
  yellow_echo '===> Running setup.sh script...'

  local username=${USERNAME:-"vagrant"}

  green_echo "===> Add ${username} user to the sudoers list and allow it to sudo without entering password"
  disable_sudo_password ${username}

  yellow_echo "===> Update and upgrade all the things"
  green_echo "===> Update the package list"
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
  green_echo "===> Upgrade all installed packages"
  DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

  green_echo "===> Installing packages"
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y install pv tree vim curl zip unzip 

  green_echo "===> Minimize the number of running daemons..."
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge snapd
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove

  green_echo "===> Disabling cloud init"
  # This delays boot by *a lot* for no apparent reason...
  touch /etc/cloud/cloud-init.disabled
  systemctl -q mask systemd-networkd-wait-online

  green_echo "===> Disabling unattended-upgrades"
  # We don't want the system to change behind our backs...
  systemctl -q is-active unattended-upgrades && sudo systemctl stop unattended-upgrades
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge unattended-upgrades

  # green_echo "===> Setting up firewall"
  # setup_ufw

  yellow_echo "===> setup.sh Done!"
}

main
