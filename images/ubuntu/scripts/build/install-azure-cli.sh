#!/bin/bash -e
################################################################################
##  File:  install-azure-cli.sh
##  Desc:  Install Azure CLI (az)
################################################################################

if [[ "$ARCH" == "ppc64le" || "$ARCH" == "s390x" ]]; then
    # Placeholder for ARCH-specific logic
    echo "No actions defined for $ARCH architecture."
else
    # Install Azure CLI (instructions taken from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash

    echo "azure-cli https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt" >> $HELPER_SCRIPTS/apt-sources.txt

    rm -f /etc/apt/sources.list.d/azure-cli.list
    rm -f /etc/apt/sources.list.d/azure-cli.list.save
fi