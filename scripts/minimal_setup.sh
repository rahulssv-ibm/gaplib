#!/bin/bash
set -e  # Exit on any error
set -o pipefail  # Fail if any command in a pipeline fails

# toolset_file_name="toolset-2204.json"
toolset_file_name="toolset-$(echo "$2" | sed 's/\.//g').json"

image_folder="/imagegeneration"
helper_script_folder="/imagegeneration/helpers"
installer_script_folder="/imagegeneration/installers"
imagedata_file="/imagegeneration/imagedata.json"

sudo mkdir -p "${installer_script_folder}"
sudo chmod -R 777 "${installer_script_folder}"
sudo cp -r helpers "${helper_script_folder}"
sudo cp ../toolsets/toolset-2204.json "${installer_script_folder}/toolset.json"
sudo cp -r build/ "${installer_script_folder}"
sudo cp -r ../assets/post-gen "${image_folder}"

if [ ! -d "${image_folder}/post-generation" ]; then
    sudo mv "${image_folder}/post-gen" "${image_folder}/post-generation"
fi

# Default environment variable values
ARCH=${ARCH:-$(uname -m)}
HELPER_SCRIPTS="${helper_script_folder}"
IMAGE_FOLDER="${image_folder}"
IMAGE_OS=$(echo "$1" | tr '[:upper:]' '[:lower:]')
IMAGE_VERSION=$2
IMAGEDATA_FILE="${imagedata_file}"
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
run_script "${path_root}/../scripts/build/configure-apt-mock.sh"
echo "Setting user ubuntu with sudo privileges"

# Install Configure apt
# run_script "${path_root}/../scripts/build/install-ms-repos.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS"
run_script "${path_root}/../scripts/build/configure-apt.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS"

# Configure limits
run_script "${path_root}/../scripts/build/configure-limits.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS"

# Configure limits
run_script "${path_root}/../scripts/build/configure-image-data.sh" "IMAGE_VERSION" "IMAGEDATA_FILE"

# Configure limits
run_script "${path_root}/../scripts/build/configure-environment.sh" "IMAGE_OS" "IMAGE_VERSION" "HELPER_SCRIPTS"

# List of scripts to be executed
SCRIPT_FILES=(
    "install-apt-vital.sh"
    "install-actions-cache.sh"
    "install-runner-package.sh"
    "install-apt-common.sh"
    "install-dotnetcore-sdk.sh"
    "install-git.sh"
    "install-git-lfs.sh"
    "install-github-cli.sh"
    "install-zstd.sh"
)

# Loop through all scripts and execute them
for SCRIPT_FILE in "${SCRIPT_FILES[@]}"; do
    SCRIPT_PATH="${path_root}/../scripts/build/${SCRIPT_FILE}"
    run_script "$SCRIPT_PATH" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
done

# run_script "${path_root}/../scripts/build/install-docker.sh" "DOCKERHUB_PULL_IMAGES" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

# run_script "${path_root}/../scripts/build/install-pipx-packages.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

# run_script "${path_root}/../scripts/build/install-homebrew.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

# run_script "${path_root}/../scripts/build/configure-snap.sh" "HELPER_SCRIPTS"

# echo 'Rebooting VM...'
# sudo reboot

# The cleanup script is executed after the reboot.
"${path_root}/../scripts/build/cleanup.sh"

# Configure system settings
run_script "${path_root}/../scripts/build/configure-system.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "IMAGE_FOLDER"
