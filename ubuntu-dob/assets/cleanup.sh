#!/bin/sh -eux

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

echo "autoremoving packages and cleaning apt data"
apt-get -y autoremove
apt-get -y clean

echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

sync

echo "==> Disk usage before cleanup"
echo "${DISK_USAGE_BEFORE_CLEANUP}"

echo "==> Disk usage after cleanup"
df -h

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
