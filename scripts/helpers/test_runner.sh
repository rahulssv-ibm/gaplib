#!/bin/bash
export SOURCE=$(readlink -f ${BASH_SOURCE[0]})
export SRCDIR=$(dirname ${SOURCE})
export ARCH=`uname -m`
export OS_NAME="${OS_NAME:-ubuntu}"
export OS_VERSION="${OS_VERSION:-22.04}"
export LXD_CONTAINER="${OS_NAME}:${OS_VERSION}"
export BUILD_HOME="/home/ubuntu"

export BUILD_PREREQS_PATH="${SRCDIR}/build-files"

if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
    echo "Check the BUILD_PREREQS_PATH specification" >&2
    return 3
fi
export PATCH_FILE="${PATCH_FILE:-runner-main-sdk8-${ARCH}-test.patch}"

export BUILD_CONTAINER
BUILD_CONTAINER="gha-test"
export BUILD_HOME="/home/ubuntu"

echo "Copy the build-image script into gha-builder"
lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/setup_runner.sh" "${BUILD_CONTAINER}${BUILD_HOME}/setup_runner.sh"

echo "Copy the patch file into gha-builder"
lxc file push ${BUILD_PREREQS_PATH}/patches/${PATCH_FILE} "${BUILD_CONTAINER}${BUILD_HOME}/runner-sdk-8.patch"
  
echo "Running build-image.sh"
lxc exec "${BUILD_CONTAINER}" --user 1000 --group 1000 -- ${BUILD_HOME}/setup_runner.sh


