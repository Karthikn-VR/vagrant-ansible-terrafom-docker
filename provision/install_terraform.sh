#!/usr/bin/env bash
set -e

# Install Terraform
sudo apt-get install -y wget unzip

TERRAFORM_VERSION="1.9.5"   # change if needed
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

terraform -version
