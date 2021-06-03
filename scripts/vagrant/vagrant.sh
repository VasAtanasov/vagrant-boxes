#!/bin/bash 

# Enable exit/failure on error.
set -eux

HOME_DIR="/home/vagrant";

sudo cp /etc/sudoers /etc/sudoers.bak
sudo bash -c "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub";
mkdir -p "$HOME_DIR"/.ssh
if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate "$pubkey_url" -O "$HOME_DIR"/.ssh/authorized_keys;
elif command -v curl >/dev/null 2>&1; then
    curl --insecure --location "$pubkey_url" > "$HOME_DIR"/.ssh/authorized_keys;
else
    echo "Cannot download vagrant public key";
    exit 1;
fi

# Ensure the permissions are set correct to avoid OpenSSH complaints.
chown -R vagrant:vagrant "$HOME_DIR"/.ssh
chmod 0600 "$HOME_DIR"/.ssh/authorized_keys
chmod 0700 "$HOME_DIR"/.ssh


# Mark the vagrant box build time.
date --utc | sudo tee /etc/vagrant_box_build_time
