#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"

VBOX_VER=$(dmidecode | grep -i vboxver | grep -E -o '[[:digit:]\.]+' | tail -n 1)
ISO="VBoxGuestAdditions_$VBOX_VER.iso"
WEBSERVER="https://download.virtualbox.org/virtualbox/${VBOX_VER}"
URL="${WEBSERVER}/${ISO}"
LOCAL_FILE="${HOME_DIR}/${ISO}"

if command -v wget >/dev/null 2>&1; then
  wget --no-check-certificate "$URL" -P "${HOME_DIR}/"
elif command -v curl >/dev/null 2>&1; then
  curl --insecure --location "$URL" --output "${LOCAL_FILE}"
else
  echo "Cannot download $ISO"
  exit 1
fi

# mount the ISO to /tmp/vbox
mkdir -p /tmp/vbox
mount -o loop "$LOCAL_FILE" /tmp/vbox

requirements="build-essential dkms bzip2 tar the gcc make perl g++ libc6-dev linux-headers-$(uname -r)"

echo "requirements: $requirements"

echo "installing deps necessary to compile kernel modules"
sudo apt-get update -qq >/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $requirements >/dev/null

echo "installing the vbox additions"
# this install script fails with non-zero exit codes for no apparent reason so we need better ways to know if it worked
/tmp/vbox/VBoxLinuxAdditions.run --nox11 || true

if ! modinfo vboxsf >/dev/null 2>&1; then
  echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
  exit 1
fi

echo "unmounting and removing the vbox ISO"
umount /tmp/vbox
rm -rf /tmp/vbox
rm -f "$LOCAL_FILE"

echo "removing kernel dev packages and compilers we no longer need"
# apt-get remove -y build-essential gcc g++ make libc6-dev dkms linux-headers-"$(uname -r)"
sudo apt-get remove -y $requirements

echo "removing leftover logs"
rm -rf /var/log/vboxadd*

username="vagrant"
vbGroup="vboxsf"

echo "===> Adding ${username} user to the ${vbGroup} group"

if grep -q $vbGroup /etc/group; then
  sudo usermod -aG ${vbGroup} ${username}
else
  echo "Group ${vbGroup} does not exist"
fi
