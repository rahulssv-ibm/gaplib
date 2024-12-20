#!/bin/bash
set -x
set -e  # Exit on any error
set -o pipefail  # Fail if any command in a pipeline fails

toolset_file_name="toolset-2204.json"

image_folder="/imagegeneration"
helper_script_folder="/imagegeneration/helpers"
installer_script_folder="/imagegeneration/installers"

mkdir -p "${installer_script_folder}"
chmod -R 777 "${installer_script_folder}"
cp -r helpers "${helper_script_folder}"
cp ../toolsets/toolset-2204.json "${installer_script_folder}/toolset.json"

# Default environment variable values
HELPER_SCRIPTS="${helper_script_folder}"
DEBIAN_FRONTEND="noninteractive"
INSTALLER_SCRIPT_FOLDER="${installer_script_folder}"
DOCKERHUB_PULL_IMAGES="NO"
# Define path.root, assuming it's the current directory
path_root="${PWD}"

# Function to execute the script with passed environment variables
run_script() {
    local script_path="$1"  # First argument is the combined path to the script
    shift  # Shift the first argument (script path) so the remaining are environment variables

    # Initialize an empty array to store the environment variables
    local env_vars=()

    # Loop through the environment variable names and construct the env_vars array
    for var_name in "$@"; do
        if [[ -n "${!var_name}" ]]; then
            env_vars+=("${var_name}=${!var_name}")  # Add the env var in key=value format
        fi
    done

    # Convert the env_vars array into a space-separated string for export
    local env_vars_string="${env_vars[*]}"

    # Print and execute the script with the environment variables
    echo "Executing: $script_path with environment variables: $env_vars_string"
    sudo sh -c "${env_vars_string} ${script_path}"
}

# Add apt wrapper to implement retries

# List of scripts to be executed
SCRIPT_FILES=(
      
)

# Loop through all scripts and execute them
for SCRIPT_FILE in "${SCRIPT_FILES[@]}"; do
    SCRIPT_PATH="${path_root}/../scripts/build/${SCRIPT_FILE}"
    run_script "$SCRIPT_PATH" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"
done

run_script "${path_root}/../scripts/build/install-docker.sh" "DOCKERHUB_PULL_IMAGES" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

run_script "${path_root}/../scripts/build/install-pipx-packages.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

run_script "${path_root}/../scripts/build/install-homebrew.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

run_script "${path_root}/../scripts/build/configure-snap.sh" "HELPER_SCRIPTS"

# echo 'Rebooting VM...'
# sudo reboot

# The cleanup script is executed after the reboot.
"${path_root}/../scripts/build/cleanup.sh"

# Configure system settings
run_script "${path_root}/../scripts/build/configure-system.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

sleep 30
/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
