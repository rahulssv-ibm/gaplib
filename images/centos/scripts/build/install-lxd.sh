#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

sudo snap install lxd
echo "Waiting for LXD daemon to start..."
sudo systemctl start snap.lxd.daemon
sudo systemctl enable snap.lxd.daemon

# Check if LXD command is now available
if ! command -v lxd &> /dev/null; then
  echo "LXD command still not found. Please check your snap installation."
  exit 1
else
  lxd init --auto
  echo "LXD is ready to use!"
fi
systemctl restart systemd-sysctl