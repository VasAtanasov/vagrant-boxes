
VERSION="11.0.6-amzn"
MAVEN_VERSION="3.6.3"

apt-get update && \
	apt-get install -y zip unzip curl && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*

curl -s "https://get.sdkman.io" | bash

# Installing Java and Maven, removing some unnecessary SDKMAN files
bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    yes | sdk install java $JAVA_VERSION && \
    yes | sdk install maven $MAVEN_VERSION && \
    rm -rf $HOME/.sdkman/archives/* && \
    rm -rf $HOME/.sdkman/tmp/*"

# ENTRYPOINT bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && $0 $@" 

MAVEN_HOME="$HOME/.sdkman/candidates/maven/current" 
JAVA_HOME="$HOME/.sdkman/candidates/java/current" 
PATH="$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH" 