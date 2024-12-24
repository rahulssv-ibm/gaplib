#!/bin/bash -e
################################################################################
##  File:  install-git.sh
##  Desc:  Install Git and Git-FTP
################################################################################
# Load helper functions (if any)
source $HELPER_SCRIPTS/install.sh

# Enable EPEL repository for additional packages
sudo dnf install -y epel-release

# Install Git
sudo dnf install -y git

# Git version 2.35.2 introduces a security fix that breaks action/checkout
cat <<EOF | sudo tee -a /etc/gitconfig
[safe]
        directory = *
EOF

# Install Git-FTP
sudo dnf install -y git-ftp

# Document installed Git version
git --version | sudo tee -a $HELPER_SCRIPTS/package-versions.txt

# Add well-known SSH host keys to known_hosts
ssh-keyscan -t rsa,ecdsa,ed25519 github.com | sudo tee -a /etc/ssh/ssh_known_hosts
ssh-keyscan -t rsa ssh.dev.azure.com | sudo tee -a /etc/ssh/ssh_known_hosts