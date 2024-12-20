#!/bin/bash -e
################################################################################
##  File:  install-runner-package.sh
##  Desc:  Download and Install runner package
################################################################################
set -x

# Source the helpers for use with the script
source "$HELPER_SCRIPTS/install.sh"

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Download the runner package
    download_url=$(resolve_github_release_asset_url "actions/runner" 'test("actions-runner-linux-x64-[0-9]+\\.[0-9]+\\.[0-9]+\\.tar\\.gz$")' "latest")
    archive_name="${download_url##*/}"
    archive_path=$(download_with_retry "$download_url")

    # Create directory and move the downloaded file
    mkdir -p /opt/runner-cache
    mv "$archive_path" "/opt/runner-cache/$archive_name"
fi
