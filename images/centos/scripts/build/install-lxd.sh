#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

sudo snap install lxd
lxd init --auto
# lxc storage set default volume.block.filesystem xfs
systemctl restart systemd-sysctl