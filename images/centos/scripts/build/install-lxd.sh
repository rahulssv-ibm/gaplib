#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

# Install LXD using snap
echo "Installing LXD using snap..."
sudo snap install lxd

# Wait for LXD service to become active
echo "Waiting for LXD service to be active..."
wait_for_service snap.lxd.daemon 60  # Wait up to 60 seconds for LXD service to be active

# Initialize LXD
echo "Initializing LXD..."
lxd init --auto
echo "LXD is ready to use!"