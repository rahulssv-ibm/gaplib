#!/bin/bash
set -xe  # Exit on any error

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

PATCH_FILE="${PATCH_FILE:-runner-main-sdk8-${ARCH}.patch}"