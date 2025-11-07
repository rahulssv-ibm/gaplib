#!/bin/bash -e
################################################################################
##  File:  install-ninja.sh
##  Desc:  Install ninja-build
################################################################################

# Source the helpers for use with the script
# shellcheck disable=SC1091
source "$HELPER_SCRIPTS"/install.sh

# Set architecture-specific variables using a case statement for clarity
case "$ARCH" in
    "ppc64le" | "s390x")
        install_dpkgs ninja-build
        exit 0
        ;;
    *)
        ;;
esac

# Install ninja
download_url=$(resolve_github_release_asset_url "ninja-build/ninja" "endswith(\"ninja-linux.zip\")" "latest")
ninja_binary_path=$(download_with_retry "${download_url}")

# Unzip the ninja binary
unzip -qq "$ninja_binary_path" -d /usr/local/bin

