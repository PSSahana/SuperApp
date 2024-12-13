#!/bin/bash
sudo apt update -y
sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -xzvf apache-maven-3.9.9-bin.tar.gz
sudo mv apache-maven-3.9.9 /opt/maven
cat <<EOF | sudo tee /etc/profile.d/maven.sh
export MAVEN_HOME=/opt/maven
export PATH=\$PATH:\$MAVEN_HOME/bin
EOF
source /etc/profile.d/maven.sh
echo $MAVEN_HOME
echo $PATH
mvn --version

/home/ubuntu/.jenkins/workspace/test@tmp/durable-7db44299/script.sh.copy: 1: mvn: not found