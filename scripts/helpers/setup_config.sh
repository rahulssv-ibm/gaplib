#!/bin/bash
set -e  # Exit on any error
set -ox pipefail  # Fail if any command in a pipeline fails

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
SETUP=${3:-"minimal"} # Default to "minimal" if SETUP is not set
IMAGEDATA_FILE="${imagedata_file}"
DEBIAN_FRONTEND="noninteractive"
INSTALLER_SCRIPT_FOLDER="${installer_script_folder}"
DOCKERHUB_PULL_IMAGES="NO"
# Define path.root, assuming it's the current directory
IMGDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../images/${IMAGE_OS}"

sudo mkdir -p "${installer_script_folder}"
sudo chmod -R 777 "${installer_script_folder}"
sudo cp -r ${IMGDIR}/scripts/helpers/. "${helper_script_folder}"
sudo cp ${IMGDIR}/toolsets/${toolset_file_name} "${installer_script_folder}/toolset.json"
sudo cp -r ${IMGDIR}/scripts/build/. "${installer_script_folder}"
sudo cp -r ${IMGDIR}/assets/post-gen "${image_folder}"

if [ ! -d "${image_folder}/post-generation" ]; then
    sudo mv "${image_folder}/post-gen" "${image_folder}/post-generation"
fi