#!/bin/bash
set -e  # Exit on any error
set -o pipefail  # Fail if any command in a pipeline fails

toolset_file_name="toolset-$(echo "$2" | sed 's/\.//g').json"
image_folder="/imagegeneration"
helper_script_folder="/imagegeneration/helpers"
installer_script_folder="/imagegeneration/installers"
imagedata_file="/imagegeneration/imagedata.json"

# Default environment variable values
ARCH=${ARCH:-$(uname -m)}
HELPER_SCRIPTS="${helper_script_folder}"
IMAGE_FOLDER="${image_folder}"
IMAGE_OS=$1
IMAGE_VERSION=$2
IMAGEDATA_FILE="${imagedata_file}"
DEBIAN_FRONTEND="noninteractive"
INSTALLER_SCRIPT_FOLDER="${installer_script_folder}"
DOCKERHUB_PULL_IMAGES="NO"
# Define path.root, assuming it's the current directory
export SOURCE=$(readlink -f "${BASH_SOURCE[0]}")
export SRCDIR=$(dirname "${SOURCE}")

sudo mkdir -p "${installer_script_folder}"
sudo chmod -R 777 "${installer_script_folder}"
sudo cp -r ${SRCDIR}/scripts/helpers "${helper_script_folder}"
sudo cp ${SRCDIR}/toolsets/${toolset_file_name} "${installer_script_folder}/toolset.json"
sudo cp -r ${SRCDIR}/scripts/build/ "${installer_script_folder}"
sudo cp -r ${SRCDIR}/assets/post-gen "${image_folder}"

if [ ! -d "${image_folder}/post-generation" ]; then
    sudo mv "${image_folder}/post-gen" "${image_folder}/post-generation"
fi

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

# Configure limits
run_script "${SRCDIR}/scripts/build/configure-limits.sh" 

# Configure image data
run_script "${SRCDIR}/scripts/build/configure-image-data.sh" "IMAGE_VERSION" "IMAGEDATA_FILE"

# Configure environment
run_script "${SRCDIR}/scripts/build/configure-environment.sh" "IMAGE_OS" "IMAGE_VERSION" "HELPER_SCRIPTS"

if [[ "$IMAGE_OS" == *"ubuntu"* ]]; then
    # Add apt wrapper to implement retries
    run_script "${SRCDIR}/scripts/build/configure-apt-mock.sh"
    echo "Setting user ubuntu with sudo privileges"

    # Install Configure apt
    run_script "${SRCDIR}/scripts/build/configure-apt.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS"

    run_script "${SRCDIR}/scripts/build/install-apt-vital.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

    run_script "${SRCDIR}/scripts/build/install-apt-common.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

    run_script "${SRCDIR}/scripts/build/configure-dpkg.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"
elif [[ "$IMAGE_OS" == *"centos"* ]]; then
    # Add apt wrapper to implement retries
    run_script "${SRCDIR}/scripts/build/configure-yum-mock.sh"
    echo "Setting user ubuntu with sudo privileges"

    # Install Configure apt
    run_script "${SRCDIR}/scripts/build/configure-dnf.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS"

    run_script "${SRCDIR}/scripts/build/install-dnf-vital.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

    run_script "${SRCDIR}/scripts/build/install-dnf-common.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

    run_script "${SRCDIR}/scripts/build/configure-dnfpkg.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" 

fi

SETUP=${3:-"minimal"} # Default to "minimal" if SETUP is not set

# Initialize an empty array for script files
SCRIPT_FILES=()

# Define scripts for each setup type
if [ "$SETUP" == "minimal" ]; then
    # List of scripts to be executed
    SCRIPT_FILES=(
        "install-dotnetcore-sdk.sh"
        "install-runner-package.sh"
        "install-actions-cache.sh"
        "install-git.sh"
        "install-git-lfs.sh"
        "install-github-cli.sh"
        "install-zstd.sh"
    )
elif [ "$SETUP" == "complete" ]; then
    # List of scripts to be executed
    SCRIPT_FILES=(
        "install-dotnetcore-sdk.sh"
        "install-runner-package.sh"
        "install-actions-cache.sh"
        "install-azcopy.sh"
        "install-azure-cli.sh"
        "install-azure-devops-cli.sh"
        "install-bicep.sh"
        "install-aliyun-cli.sh"
        "install-apache.sh"
        "install-aws-tools.sh"
        "install-clang.sh"
        "install-swift.sh"
        "install-cmake.sh"
        "install-codeql-bundle.sh"
        "install-container-tools.sh"
        "install-firefox.sh"
        "install-microsoft-edge.sh"
        "install-gcc-compilers.sh"
        "install-gfortran.sh"
        "install-git.sh"
        "install-git-lfs.sh"
        "install-github-cli.sh"
        "install-google-chrome.sh"
        "install-google-cloud-cli.sh"
        "install-haskell.sh"
        "install-heroku.sh"
        "install-java-tools.sh"
        "install-kubernetes-tools.sh"
        "install-oc-cli.sh"
        "install-leiningen.sh"
        "install-miniconda.sh"
        "install-kotlin.sh"
        "install-mysql.sh"
        "install-mssql-tools.sh"
        "install-sqlpackage.sh"
        "install-nginx.sh"
        "install-nvm.sh"
        "install-nodejs.sh"
        "install-bazel.sh"
        "install-php.sh"
        "install-postgresql.sh"
        "install-pulumi.sh"
        "install-ruby.sh"
        "install-rlang.sh"
        "install-rust.sh"
        "install-julia.sh"
        "install-selenium.sh"
        "install-terraform.sh"
        "install-packer.sh"
        "install-vcpkg.sh"
        "install-yq.sh"
        "install-android-sdk.sh"
        "install-pypy.sh"
        "install-python.sh"
        "install-zstd.sh"
    )
    run_script "${SRCDIR}/scripts/build/install-pipx-packages.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

    run_script "${SRCDIR}/scripts/build/install-homebrew.sh" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"
else
    echo "Invalid SETUP value. Please set SETUP to 'minimal' or 'complete'."
    exit 1
fi

# Loop through all scripts and execute them
for SCRIPT_FILE in "${SCRIPT_FILES[@]}"; do
    SCRIPT_PATH="${SRCDIR}/scripts/build/${SCRIPT_FILE}"
    run_script "$SCRIPT_PATH" "DEBIAN_FRONTEND" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
done

run_script "${SRCDIR}/scripts/build/install-docker.sh" "DOCKERHUB_PULL_IMAGES" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER"

run_script "${SRCDIR}/scripts/build/configure-snap.sh" "HELPER_SCRIPTS"

# echo 'Rebooting VM...'
# sudo reboot

# The cleanup script is executed after the reboot.
"${SRCDIR}/scripts/build/cleanup.sh"

# Configure system settings
run_script "${SRCDIR}/scripts/build/configure-system.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "IMAGE_FOLDER"
