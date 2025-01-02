#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

sudo snap install lxd
echo "Waiting for LXD daemon to start..."
sudo systemctl restart systemd-sysctl
sudo systemctl start snap.lxd.daemon
sudo systemctl enable snap.lxd.daemon

# Function to check LXD availability
check_lxd() {
  command -v lxd &> /dev/null
}

# Retry mechanism
attempts=0
max_attempts=3
while ! check_lxd; do
  attempts=$((attempts + 1))
  if [ "$attempts" -ge "$max_attempts" ]; then
    echo "LXD command not found after $max_attempts attempts. Exiting..."
    exit 1
  fi
  echo "LXD command not found. Retrying in 10 seconds... ($attempts/$max_attempts)"
  sleep 10
done
lxd init --auto
echo "LXD is ready to use!"
