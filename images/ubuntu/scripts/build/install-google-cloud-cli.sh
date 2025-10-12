#!/bin/bash -e
################################################################################
##  File:  install-google-cloud-cli.sh
##  Desc:  Install the Google Cloud CLI
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" || "$ARCH" == "s390x" ]]; then
    # Placeholder for ARCH-specific logic
    echo "No actions defined for $ARCH architecture."
else
    REPO_URL="https://packages.cloud.google.com/apt"

    # Install the Google Cloud CLI
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] $REPO_URL cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list
    wget -qO- https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor > /usr/share/keyrings/cloud.google.gpg
    update_dpkgs
    install_dpkgs google-cloud-cli

    # remove apt
    rm /etc/apt/sources.list.d/google-cloud-sdk.list
    rm /usr/share/keyrings/cloud.google.gpg

    # add repo to the apt-sources.txt
    echo "google-cloud-sdk $REPO_URL" >> $HELPER_SCRIPTS/apt-sources.txt
fi
