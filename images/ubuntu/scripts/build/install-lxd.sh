#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

sudo snap install lxd
cat lxd-preseed.yaml | lxd init --preseed
# lxc storage set default volume.block.filesystem xfs
systemctl restart systemd-sysctl