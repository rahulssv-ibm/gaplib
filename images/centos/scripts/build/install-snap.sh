#!/bin/bash -e
################################################################################
##  File:  install-snap.sh
##  Desc:  Install snapd
################################################################################
source $HELPER_SCRIPTS/install.sh

# Install snapd if not already installed
echo "Installing snapd..."
if ! rpm -q snapd &>/dev/null; then
    sudo dnf -y install epel-release
    sudo dnf -y install snapd
else
    echo "snapd is already installed."
fi

# Enable and start snapd.socket
echo "Enabling and starting snapd.socket..."
sudo systemctl enable --now snapd.socket

# Create symbolic link for snap directory if not already exists
if [ ! -L /snap ]; then
    echo "Creating symbolic link for /snap..."
    sudo ln -s /var/lib/snapd/snap /snap
else
    echo "Symbolic link for /snap already exists."
fi

# Ensure /snap/bin is in the PATH
echo "Checking if /snap/bin is in the PATH..."
if [[ "$PATH" != *"/snap/bin"* ]]; then
    echo "/snap/bin is not in the PATH. Adding it now..."
    export PATH=/snap/bin:$PATH
    echo "export PATH=/snap/bin:$PATH" >> ~/.bashrc  # Persist for future sessions
    echo "/snap/bin has been added to the PATH."
else
    echo "/snap/bin is already in the PATH."
fi

# Check snapd.seeded.service status
echo "Checking snapd.seeded.service status..."
if sudo systemctl is-active --quiet snapd.seeded.service; then
    echo "snapd.seeded.service is already completed."
else
    sudo systemctl restart snapd.seeded.service
    sudo systemctl restart snapd.service
    echo "snapd.seeded.service has not completed. Waiting for it to finish..."
    wait_for_service snapd.seeded.service 10  # Wait up to 60 seconds
fi

echo "Snapd setup and initialization completed successfully."