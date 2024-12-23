#!/bin/bash

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}
export PATH=/snap/bin:${PATH}
export SOURCE=$(readlink -f "${BASH_SOURCE[0]}")
export SRCDIR=$(dirname "${SOURCE}")
  
export ARCH=`uname -m`
export ACTION_RUNNER="https://github.com/actions/runner"
export EXPORT="distro/lxc-runner"
export HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
export HOST_OS_VERSION=$(grep -E 'VERSION_ID' /etc/os-release | cut -d'=' -f2 | tr -d '"')
export SETUP=$3
export BUILD_HOME="/home/runner"

local BUILD_PREREQS_PATH="${SRCDIR}"
if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
  msg "Check the BUILD_PREREQS_PATH specification" >&2
  return 3
fi
local PATCH_FILE="${PATCH_FILE:-runner-main-sdk8-${ARCH}.patch}"
msg "Copy the patch file into gha-builder"
cp -r "${BUILD_PREREQS_PATH}/../patches/${PATCH_FILE}" "${BUILD_HOME}/runner-sdk-8.patch"

msg "Copy the setup.sh script into gha-builder"
cp -r ${BUILD_PREREQS_PATH}/setup.sh "${BUILD_HOME}/setup.sh"
chmod -R 0755 ${BUILD_HOME}/setup.sh
  
msg "Copy the supported packages list into the gha-builder"
cp -r "${BUILD_PREREQS_PATH}/../images/${HOST_OS_NAME}" "${BUILD_HOME}" --recursive
chmod -R 0755 ${BUILD_HOME}

msg "Copy the register-runner.sh script into gha-builder"
cp -r ${BUILD_PREREQS_PATH}/register-runner.sh "/opt/register-runner.sh"
chmod -R 0755 /opt/register-runner.sh

msg "Copy the /etc/rc.local - required in case podman is used"
cp -r ${BUILD_PREREQS_PATH}/assets/rc.local "/etc/rc.local"
chmod -R 0755 /etc/rc.local

msg "Copy the LXD preseed configuration"
cp -r ${BUILD_PREREQS_PATH}/assets/lxd-preseed-dir.yaml "/tmp/lxd-preseed.yaml"
chmod -R 0755 /tmp/lxd-preseed.yaml

msg "Copy the gha-service unit file into gha-builder"
cp -r ${BUILD_PREREQS_PATH}/assets/gha-runner.service "/etc/systemd/system/gha-runner.service"
chmod -R 0755 /etc/systemd/system/gha-runner.service

msg "Copy the apt and dpkg overrides into gha-builder - these prevent doc files from being installed"
cp -r "${BUILD_PREREQS_PATH}/assets/99synaptics" "/etc/apt/apt.conf.d/99synaptics"
chmod -R 0644 /etc/apt/apt.conf.d/99synaptics
cp -r "${BUILD_PREREQS_PATH}/assets/01-nodoc" "/etc/dpkg/dpkg.cfg.d/01-nodoc"
chmod -R 0644 /etc/dpkg/dpkg.cfg.d/01-nodoc
