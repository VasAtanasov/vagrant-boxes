#!/bin/bash

set -e

JAVA_VERSION=${JAVA_VERSION:-"11.0.11.9.1-amzn"}
MAVEN_VERSION=${MAVEN_VERSION:-"3.6.3"}

echo "Java candidate: ${JAVA_VERSION}"
echo "Maven candidate: ${MAVEN_VERSION}"

sudo apt-get update &&
  sudo apt-get install -y zip unzip curl &&
  sudo rm -rf /var/lib/apt/lists/* &&
  sudo rm -rf /tmp/*

USERNAME=${USERNAME:-vagrant}

curl -s "https://get.sdkman.io" | bash

USER_HOME="/home/${USERNAME}"

source "$USER_HOME/.sdkman/bin/sdkman-init.sh" &&
  echo "Installing java version: ${JAVA_VERSION}" &&
  yes | sdk install java "$JAVA_VERSION" &&
  echo "Installing maven version: ${MAVEN_VERSION}" &&
  yes | sdk install maven "$MAVEN_VERSION" &&
  rm -rf "$USER_HOME/.sdkman/archives/*" &&
  rm -rf "$USER_HOME/.sdkman/tmp/*"

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
