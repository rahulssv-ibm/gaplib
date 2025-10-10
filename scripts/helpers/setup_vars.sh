#!/bin/bash
set -e  # Exit on any error
set -o allexport  # Enable exporting of all variables

# Default environment variable values
ARCH=${ARCH:-$(uname -m)}
IMAGE_OS=$1
IMAGE_VERSION=$2
WORKER_TYPE=${3:-""} # Default to "" if WORKER_TYPE is not set
WORKER_CPU=${4:-""} # Default to "" if WORKER_CPU is not set
SETUP=${5:-"minimal"} # Default to "minimal" if SETUP is not set

toolset_file_name="toolset-$(echo "$2" | sed 's/\.//g').json"
image_folder="/var/tmp/imagegeneration-${IMAGE_OS}-${IMAGE_VERSION}"
helper_script_folder="${image_folder}/helpers"
installer_script_folder="${image_folder}/installers"
imagedata_file="${image_folder}/imagedata.json"

HELPER_SCRIPTS="${helper_script_folder}"
IMAGE_FOLDER="${image_folder}"
IMAGEDATA_FILE="${imagedata_file}"
DEBIAN_FRONTEND="noninteractive"
INSTALLER_SCRIPT_FOLDER="${installer_script_folder}"
DOCKERHUB_PULL_IMAGES="NO"
PATCH_FILE="${PATCH_FILE:-runner-sdk8-${ARCH}.patch}"