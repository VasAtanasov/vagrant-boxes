#!/bin/bash

set -eux

JAVA_VERSION=${JAVA_VERSION:-"11.0.11.9.1-amzn"}
MAVEN_VERSION=${MAVEN_VERSION:-"3.8.1"}

echo "Java candidate: ${JAVA_VERSION}"
echo "Maven candidate: ${MAVEN_VERSION}"

echo "Updateing the apt package index and installing packages needed by sdkman"
sudo apt-get update -qq >/dev/null &&
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zip unzip curl >/dev/null &&
  sudo rm -rf /var/lib/apt/lists/* &&
  sudo rm -rf /tmp/*

USERNAME=${USERNAME:-vagrant}

echo "Installing sdkman for user ${USERNAME}"
curl -s "https://get.sdkman.io" | bash 

USER_HOME="/home/${USERNAME}"

source "$USER_HOME/.sdkman/bin/sdkman-init.sh"

echo "Installing java version: ${JAVA_VERSION}"
yes | sdk install java "$JAVA_VERSION"

echo "Installing maven version: ${MAVEN_VERSION}"
yes | sdk install maven "$MAVEN_VERSION"

echo "Cleaning up"
rm -rf "$USER_HOME/.sdkman/archives/*"
rm -rf "$USER_HOME/.sdkman/tmp/*"

echo "Adding maven env"

INSTALL_DIR="$USER_HOME/.sdkman/candidates"
MAVEN_INSTALL_DIR="${INSTALL_DIR}/maven/current"

sudo tee -a /etc/profile.d/maven.sh >/dev/null <<EOT
#!/bin/sh
export MAVEN_HOME=${MAVEN_INSTALL_DIR}
export M2_HOME=${MAVEN_INSTALL_DIR}
export M2=${MAVEN_INSTALL_DIR}/bin
export PATH=${MAVEN_INSTALL_DIR}/bin:$PATH
EOT

source /etc/profile.d/maven.sh
