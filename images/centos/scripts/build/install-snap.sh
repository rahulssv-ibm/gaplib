#!/bin/bash -e
################################################################################
##  File:  install-snap.sh
##  Desc:  Install snapd
################################################################################
source $HELPER_SCRIPTS/install.sh
 
dnf -y install snapd

sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

if [[ ":$PATH:" == *"/snap/bin"* ]]; then
    echo "/snap/bin is already in the PATH"
else
    echo "/snap/bin is not in the PATH. Adding it now..."
    export PATH=/snap/bin:$PATH
    echo "export PATH=/snap/bin:$PATH" >> ~/.bashrc  # Persist for future sessions
    echo "/snap/bin has been added to the PATH"
fi