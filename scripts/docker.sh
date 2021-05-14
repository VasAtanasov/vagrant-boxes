#!/bin/bash

set -e

if [ -x "$(command -v docker)" ]; then
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get purge docker-ce docker-ce-cli containerd.io
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
else
  echo "There is no docker installed"
fi
