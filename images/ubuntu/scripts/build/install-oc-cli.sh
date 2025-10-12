#!/bin/bash -e
################################################################################
##  File:  install-oc-cli.sh
##  Desc:  Install the OC CLI
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh

# Set architecture-specific variables using a case statement for clarity
case "$ARCH" in
    "ppc64le" | "s390x")
        package_arch="$ARCH"
        ;;
    "x86_64" | *) # Default to x86_64
        package_arch="amd64"
        ;;
esac

# Install the oc CLI
download_url="https://mirror.openshift.com/pub/openshift-v4/${package_arch}/clients/ocp/latest/openshift-client-linux.tar.gz"
    
archive_path=$(download_with_retry "$download_url")

tar xzf "$archive_path" -C "/usr/local/bin" oc
