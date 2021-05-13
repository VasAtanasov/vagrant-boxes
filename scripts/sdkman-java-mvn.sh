
JAVA_VERSION=${JAVA_VERSION:-"11.0.11.9.1-amzn"}
MAVEN_VERSION=${MAVEN_VERSION:-"3.6.3"}

function execAsUser() {
    local username=${1}
    local exec_command=${2}
    sudo -u "${username}" -H bash -c "${exec_command}"
}

apt-get update && \
	apt-get install -y zip unzip curl && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*

USERNAME=${USERNAME:-vagrant}

execAsUser "${USERNAME}" "curl -s "https://get.sdkman.io" | bash"

# Installing Java and Maven, removing some unnecessary SDKMAN files
execAsUser "${USERNAME}" "source /home/${USERNAME}/.sdkman/bin/sdkman-init.sh && \
    yes | sdk install java $JAVA_VERSION && \
    yes | sdk install maven $MAVEN_VERSION && \
    rm -rf /home/$USERNAME/.sdkman/archives/* && \
    rm -rf /home/$USERNAME/.sdkman/tmp/*"

INSTALL_DIR="/home/${USERNAME}/.sdkman/candidates"
MAVEN_INSTALL_DIR="${INSTALL_DIR}/maven/current"

cat <<EOF >/etc/profile.d/maven.sh
#!/bin/sh
export MAVEN_HOME=${MAVEN_INSTALL_DIR}
export M2_HOME=${MAVEN_INSTALL_DIR}
export M2=${MAVEN_INSTALL_DIR}/bin
export PATH=${MAVEN_INSTALL_DIR}/bin:$PATH
EOF

source /etc/profile.d/maven.sh