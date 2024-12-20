#!/bin/bash -e
################################################################################
##  File:  install-bicep.sh
##  Desc:  Install bicep cli
################################################################################
set -x
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [ "$ARCH" = "ppc64le" ] ; then 
    #
    #
elif [ "$ARCH" = "s390x" ]; then
    #
    #
else
    # Install Bicep CLI
    download_url=$(resolve_github_release_asset_url "Azure/bicep" "endswith(\"bicep-linux-x64\")" "latest")
    bicep_binary_path=$(download_with_retry "${download_url}")

    # Mark it as executable
    install "$bicep_binary_path" /usr/local/bin/bicep
fi

