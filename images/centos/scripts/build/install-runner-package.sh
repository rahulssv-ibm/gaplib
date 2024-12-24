#!/bin/bash -e
################################################################################
##  File:  install-runner-package.sh
##  Desc:  Download and Install runner package
################################################################################

# Source the helpers for use with the script
source "$HELPER_SCRIPTS/install.sh"
SRC=$(readlink -f "${BASH_SOURCE[0]}")
DIR=$(dirname "${SRC}")

if [[ "$ARCH" == "ppc64le" || "$ARCH" == "s390x" ]]; then 
    sudo sh -c "${DIR}/configure-runner.sh"
else
    # Download the runner package
    download_url=$(resolve_github_release_asset_url "actions/runner" 'test("actions-runner-linux-x64-[0-9]+\\.[0-9]+\\.[0-9]+\\.tar\\.gz$")' "latest")
    archive_name="${download_url##*/}"
    archive_path=$(download_with_retry "$download_url")

    # Create directory and move the downloaded file
    mkdir -p /opt/runner-cache
    mv "$archive_path" "/opt/runner-cache/$archive_name"
fi