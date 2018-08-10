#!/bin/bash

echo "Download Bluemix CLI"
curl -sL https://ibm.biz/idt-installer | bash

# Install Armada CS plugin
echo "Set region"
ibmcloud cs region-set eu-central

echo "Install kubectl"
wget --quiet --output-document=/tmp/Bluemix_CLI/bin/kubectl  https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x /tmp/Bluemix_CLI/bin/kubectl

if [ -n "$DEBUG" ]; then
  bx --version
  bx plugin list
fi
