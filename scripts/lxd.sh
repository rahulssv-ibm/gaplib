#!/bin/bash
set -x

HELPERS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/helpers"

source ${HELPERS_DIR}/setup_vars.sh
source ${HELPERS_DIR}/setup_img.sh
source ${HELPERS_DIR}/run_script.sh

usage() {
    echo "setup-build-env [flags]"
    echo ""
    echo "Where flags:"
    echo "-a <action runner git repo>  Where to find the action runner git repo"
    echo "                             defaults to ${ACTION_RUNNER}"
    echo "-o <exported image>          Path to exported image"
    echo "                             defaults to ${EXPORT}"
    echo "-h                           Display this usage information"
    exit
}

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

ensure_lxd() {
    if ! command -v lxd &> /dev/null; then
        echo "LXD is not installed."
        echo "Installing LXD using snap..."
        if ! command -v snap &> /dev/null; then
            echo "Snap is not installed. Installing Snap..."
            run_script "${INSTALLER_SCRIPT_FOLDER}/install-snap.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
            echo "Snap installed successfully."
        fi
        echo "Installing LXD using Snap..."
        run_script "${INSTALLER_SCRIPT_FOLDER}/install-lxd.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
        if command -v lxd &> /dev/null; then
            echo "LXD installed successfully."
        else
            echo "Failed to install LXD. Please check your system configuration."
            exit 1
        fi
    else
        echo "LXD is already installed. Version: $(lxd --version)"
    fi
}

build_image() {
  
  local IMAGE_ALIAS="${IMAGE_ALIAS:-${IMAGE_OS}-${IMAGE_VERSION}-${ARCH}}"

  local BUILD_PREREQS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
      msg "Check the BUILD_PREREQS_PATH specification" >&2
      return 3
  fi

  local BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"

  msg "Launching build container ${LXD_CONTAINER}"
  lxc launch "${LXD_CONTAINER}" "${BUILD_CONTAINER}" 
  lxc ls
  
  # give container some time to wake up and remap the filesystem
  for ((i = 0; i < 90; i++))
  do
      CHECK=`lxc exec ${BUILD_CONTAINER} -- stat ${BUILD_HOME} 2>/dev/null`
      if [ -n "${CHECK}" ]; then
          break
      fi
      sleep 2s
  done

  if [ -z "${CHECK}" ]; then
      msg "Unable to start the build container" >&2
      lxc delete -f ${BUILD_CONTAINER}
      return 2
  fi

  msg "Copy the patch file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/../patches/${PATCH_FILE} "${BUILD_CONTAINER}/tmp/runner-sdk-8.patch"
  
  msg "Create /imagegeneration directory into gha-builder"
  lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- mkdir -p /imagegeneration

  msg "Copy the /imagegeneration into the gha-builder"
  lxc file push "/imagegeneration" "${BUILD_CONTAINER}/imagegeneration" --recursive

  msg "Copy the register-runner.sh script into gha-builder"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/helpers/register-runner.sh "${BUILD_CONTAINER}/opt/register-runner.sh"
 
  msg "Copy the /etc/rc.local - required in case podman is used"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/assets/rc.local "${BUILD_CONTAINER}/etc/rc.local"
  
  msg "Copy the LXD preseed configuration"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/assets/lxd-preseed-dir.yaml "${BUILD_CONTAINER}/tmp/lxd-preseed.yaml"
  
  msg "Copy the gha-service unit file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/assets/gha-runner.service "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  msg "Copy the apt and dpkg overrides into gha-builder - these prevent doc files from being installed"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/assets/99synaptics" "${BUILD_CONTAINER}/etc/apt/apt.conf.d/99synaptics"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/assets/01-nodoc" "${BUILD_CONTAINER}/etc/dpkg/dpkg.cfg.d/01-nodoc"

  msg "Setting user ubuntu with sudo privileges"
  lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- sh -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
  
  msg "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" --user 1000 --group 1000 -- sh -c  "/imagegeneration/helpers/setup_install.sh ${IMAGE_OS} ${IMAGE_VERSION} ${SETUP}"
  RC=$?

  if [ ${RC} -eq 0 ]; then
      # Until we are at lxc >= 5.19 we can't use the --reuse option on the publish command
      msg "Deleting old image"
      lxc image delete ${IMAGE_ALIAS} 2>/dev/null

      msg "Runner build complete. Creating image snapshot."
      lxc snapshot "${BUILD_CONTAINER}" "build-snapshot"
      lxc publish "${BUILD_CONTAINER}/build-snapshot" -f --alias "${IMAGE_ALIAS}" \
            --compression none \
            description="GitHub Actions ${OS_NAME} ${OS_VERSION} Runner for ${ARCH}"
  
      msg "Export the image to ${EXPORT} for use elsewhere"
      lxc image export "${IMAGE_ALIAS}" ${EXPORT}

      msg "Priming the filesystem by launching the newly built container"
      lxc launch "${IMAGE_ALIAS}" "primer"
      lxc rm -f primer
  else
      msg "Build process failed with RC: ${RC} - review log to determine cause of failure" >&2
  fi

  lxc delete -f "${BUILD_CONTAINER}"

  return ${RC}
}

run() {
  ensure_lxd "$@"
  build_image "$@"
  return $?
}

prolog() {
  PATH=/snap/bin:${PATH}
  ACTION_RUNNER="https://github.com/actions/runner"
  EXPORT="distro/lxc-runner"
  HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]')
  HOST_OS_VERSION=$(grep -E 'VERSION_ID' /etc/os-release | cut -d'=' -f2 | tr -d '"')
  BUILD_HOME="/home"
  LXD_CONTAINER="${IMAGE_OS}:${IMAGE_VERSION}"

  mkdir -p distro

#   X=`groups | grep -q lxd`
#   if [ $? -eq 1 ]; then
#       msg "Setting permissions"
#       sudo chmod 0666 /var/snap/lxd/common/lxd/unix.socket
#   fi
}

prolog
while getopts "a:o:h:" opt
do
    case "${opt}" in
        a)
            ACTION_RUNNER=${OPTARG}
            ;;
        o)
            EXPORT=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))
run "$@"
RC=$?
exit ${RC}