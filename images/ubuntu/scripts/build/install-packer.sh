#!/bin/bash -e
################################################################################
##  File:  install-packer.sh
##  Desc:  Install packer
################################################################################
set -x
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [ "$ARCH" = "ppc64le" ]; then
    # Install Packer for ppc64le
    download_url=$(curl -fsSL https://api.releases.hashicorp.com/v1/releases/packer/latest | jq -r '.builds[] | select((.arch=="ppc64le") and (.os=="linux")).url')
    archive_path=$(download_with_retry "$download_url")
    unzip -o -qq "$archive_path" -d /usr/local/bin
elif [ "$ARCH" = "s390x" ]; then
    # Install Packer for s390x
    # download_url=$(curl -fsSL https://api.releases.hashicorp.com/v1/releases/packer/latest | jq -r '.builds[] | select((.arch=="s390x") and (.os=="linux")).url')
    # archive_path=$(download_with_retry "$download_url")
    # unzip -o -qq "$archive_path" -d /usr/local/bin
else
    # Install Packer for amd64
    download_url=$(curl -fsSL https://api.releases.hashicorp.com/v1/releases/packer/latest | jq -r '.builds[] | select((.arch=="amd64") and (.os=="linux")).url')
    archive_path=$(download_with_retry "$download_url")
    unzip -o -qq "$archive_path" -d /usr/local/bin
fi