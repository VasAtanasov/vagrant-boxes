#!/bin/bash

set -e

# script to install maven

if type -p java; then
    echo "Found java executable in PATH" 
else
    echo "Install Java before installing Maven"
    exit 1
fi

if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo "Found java executable in JAVA_HOME"
else
    echo "Set JAVA_HOME before installing Maven"
    exit 1
fi

if [ $JAVA_RTN -ne 0 ]; then
    echo "Install Java before installing Maven"
    exit 1
fi

mvn -v
if [ "$?" -eq 0 ]; then
    echo "Maven is already instaled!"
    exit 0
fi

# todo: add method for checking if latest or automatically grabbing latest
mvn_version=${mvn_version:-3.6.3}
url="http://www.mirrorservice.org/sites/ftp.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz"
install_dir="/opt/maven"

if [ -d ${install_dir} ]; then
    mv ${install_dir} ${install_dir}.$(date +"%Y%m%d")
fi

mkdir ${install_dir}
curl -fsSL ${url} | tar zx --strip-components=1 -C ${install_dir}

cat <<EOF >/etc/profile.d/maven.sh
#!/bin/sh
export MAVEN_HOME=${install_dir}
export M2_HOME=${install_dir}
export M2=${install_dir}/bin
export PATH=${install_dir}/bin:$PATH
EOF

source /etc/profile.d/maven.sh

echo maven installed to ${install_dir}
mvn --version

printf "\n\nTo get mvn in your path, open a new shell or execute: source /etc/profile.d/maven.sh\n"
