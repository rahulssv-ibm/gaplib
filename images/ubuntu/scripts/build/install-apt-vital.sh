#!/bin/bash -e
################################################################################
##  File:  install-apt-vital.sh
##  Desc:  Install vital command line utilities
################################################################################

# Source the helpers for use with the script
# shellcheck disable=SC1091
# shellcheck disable=SC2086
source $HELPER_SCRIPTS/install.sh

vital_packages=$(get_toolset_value .apt.vital_packages[])
install_dpkgs --no-install-recommends $vital_packages
