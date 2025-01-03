#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

# Install LXD using snap
echo "Installing LXD using snap..."
sudo snap install lxd

echo "Checking the status of snap.lxd.daemon..."
ensure_service_is_active snap.lxd.daemon

# Initialize LXD
echo "Initializing LXD..."
lxc network create lxdbr0 ipv4.address=auto ipv4.nat=true ipv6.address=auto ipv6.nat=true
sudo -i lxd init --auto
echo "LXD is ready to use!"
