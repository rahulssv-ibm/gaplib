#!/bin/bash

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
        if ! command -v snap &> /dev/null; then
            echo "Snap is not installed. Installing Snap..."
            run_script "${HOST_INSTALLER_SCRIPT_FOLDER}/install-snap.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
            echo "Snap installed successfully."
        fi
        echo "Installing LXD using Snap..."
        run_script "${HOST_INSTALLER_SCRIPT_FOLDER}/install-lxd.sh" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"
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
  set -e

  local IMAGE_ALIAS="${IMAGE_ALIAS:-${IMAGE_OS}-${IMAGE_VERSION}-${ARCH}${WORKER_TYPE}${WORKER_CPU}}"
  local BUILD_PREREQS_PATH
  BUILD_PREREQS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

  if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
    msg "Check the BUILD_PREREQS_PATH specification" >&2
    return 3
  fi

  local BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"

  # Trap INT (Ctrl+C), TERM (kill), and EXIT signals to guarantee cleanup.
  trap "{
    msg \"Signal caught! Executing cleanup for container ${BUILD_CONTAINER}...\"
    if lxc info \"${BUILD_CONTAINER}\" &>/dev/null; then
      msg \"Stopping container ${BUILD_CONTAINER} to trigger deletion...\"
      # Container is ephemeral, so stopping it will also delete it.
      lxc stop -f \"${BUILD_CONTAINER}\"
    else
      msg \"Container ${BUILD_CONTAINER} already gone.\"
    fi
  }" INT TERM EXIT

  msg "Launching ephemeral build container ${BUILD_CONTAINER} from image ${LXD_CONTAINER}"
  lxc launch "${LXD_CONTAINER}" "${BUILD_CONTAINER}" --ephemeral
  lxc ls

  # Give container some time to wake up and remap the filesystem
  for ((i = 0; i < 90; i++)); do
    local CHECK
    CHECK=$(lxc exec "${BUILD_CONTAINER}" -- stat "${BUILD_HOME}" 2>/dev/null || true)
    if [ -n "${CHECK}" ]; then
      break
    fi
    sleep 2s
  done

  if [ -z "${CHECK}" ]; then
    msg "Unable to start the build container" >&2
    return 2
  fi

  msg "Copy the ${image_folder} contents into the gha-builder"
  lxc file push "${image_folder}" "${BUILD_CONTAINER}/var/tmp/" --recursive
  lxc exec "${BUILD_CONTAINER}" ls "${image_folder}"

  msg "Copy the register-runner.sh script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/helpers/register-runner.sh" "${BUILD_CONTAINER}/opt/register-runner.sh"

  msg "Copy the /etc/rc.local - required in case podman is used"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/assets/rc.local" "${BUILD_CONTAINER}/etc/rc.local"

  msg "Copy the gha-service unit file into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/assets/gha-runner.service" "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  msg "Copy the apt and dpkg overrides into gha-builder - these prevent doc files from being installed"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/assets/99synaptics" "${BUILD_CONTAINER}/etc/apt/apt.conf.d/99synaptics"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/assets/01-nodoc" "${BUILD_CONTAINER}/etc/dpkg/dpkg.cfg.d/01-nodoc"

  msg "Setting user runner with sudo privileges"
  lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- bash -c "useradd -c 'Action Runner' -m -s /bin/bash runner && usermod -L runner && echo 'runner ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner && chmod 440 /etc/sudoers.d/runner"

  msg "Running build-image.sh"
  if ! lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- \
    bash -c 'exec "$@"' _ "${helper_script_folder}/setup_install.sh" "${IMAGE_OS}" "${IMAGE_VERSION}" "${WORKER_TYPE}" "${WORKER_CPU}" "${SETUP}"; then

    msg "!!! The installation script inside the container failed. Triggering cleanup. !!!" >&2
    return 1 # Exit with an error code to trigger the trap and signal failure
  fi

  msg "Adding runner user to required groups"
  lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- bash -c "usermod -aG adm,users,systemd-journal,docker,lxd runner"

  msg "Clearing APT cache"
  lxc exec "${BUILD_CONTAINER}" -- apt-get -y -qq clean
  lxc exec "${BUILD_CONTAINER}" -- rm -rf ${image_folder}

  # --------------------- CRITICAL SECTION START ---------------------
  # The following operations (delete, snapshot, publish) are not safe to run in parallel.
  # We use `flock` to create a lock file. Only one script instance can hold the lock
  # at a time, forcing other instances to wait here. This prevents race conditions
  
  local LXD_PUBLISH_LOCK="/var/lock/lxd-publish.lock"
  exec 200>"${LXD_PUBLISH_LOCK}" # Open a file descriptor for the lock file
  msg "Attempting to acquire lock for image publication... (${LXD_PUBLISH_LOCK})"
  flock 200 # This command will wait until it can acquire an exclusive lock on FD 200

  msg "Lock acquired. Proceeding with atomic image publication."

  msg "Deleting old image (by fingerprint from alias ${IMAGE_ALIAS})"
  if lxc image info "${IMAGE_ALIAS}" >/dev/null 2>&1; then
    FINGERPRINT=$(lxc image info "${IMAGE_ALIAS}" | awk '/^Fingerprint:/ {print $2; exit}')
    if [ -n "${FINGERPRINT}" ]; then
        msg "Found fingerprint ${FINGERPRINT} for alias ${IMAGE_ALIAS}. Deleting image ${FINGERPRINT}..."
        lxc image delete "${FINGERPRINT}"
        msg "Image (fingerprint ${FINGERPRINT}) deleted successfully."
    else
        msg "Could not determine fingerprint for alias ${IMAGE_ALIAS}." >&2
        exit 1
    fi
  else
    msg "No existing image/alias named ${IMAGE_ALIAS} found."
  fi

  msg "Runner build complete. Creating image snapshot."
  lxc snapshot "${BUILD_CONTAINER}" "build-snapshot"

  msg "Publishing snapshot as new image: ${IMAGE_ALIAS}"
  lxc publish "${BUILD_CONTAINER}/build-snapshot" -f --alias "${IMAGE_ALIAS}" \
    --compression none \
    description="GitHub Actions ${IMAGE_OS} ${IMAGE_VERSION} Runner for ${ARCH}" \
    properties.build.commit="${BUILD_SHA}" \
    properties.build.date="${BUILD_DATE}"

  msg "Image publication complete. Releasing lock."
  # The lock on FD 200 is automatically released when the script or function exits.
  # ---------------------- CRITICAL SECTION END ----------------------

  msg "Export the image to ${EXPORT} for use elsewhere"
  lxc image export "${IMAGE_ALIAS}" "${EXPORT}/${IMAGE_OS}-${IMAGE_VERSION}-${ARCH}${WORKER_TYPE}${WORKER_CPU}"

  local PRIMER_CONTAINER
  PRIMER_CONTAINER="primer-$(date +%s)"
  msg "Priming the filesystem by launching the newly built container"
  lxc launch "${IMAGE_ALIAS}" "${PRIMER_CONTAINER}"
  lxc rm -f "${PRIMER_CONTAINER}"

  # Before exiting successfully, clear the trap so it doesn't run again on the main script's exit.
  trap - INT TERM EXIT
  lxc delete -f "${BUILD_CONTAINER}"
  return 0
}

run() {
  ensure_lxd "$@"
  build_image "$@"
  return $?
}

prolog() {
  PATH=/snap/bin:${PATH}
  ACTION_RUNNER="https://github.com/actions/runner"
  EXPORT="/opt/distro"
  HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]' | awk '{print $1}')
  HOST_OS_VERSION=$(cat /etc/os-release | grep -E 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')
  HOST_INSTALLER_SCRIPT_FOLDER="${HELPERS_DIR}/../../images/${HOST_OS_NAME}/scripts/build"
  BUILD_HOME="/home"
  BUILD_SHA=$(git rev-parse HEAD)
  BUILD_DATE=$(date -u)
  LXD_CONTAINER="${IMAGE_OS}:${IMAGE_VERSION}"

  mkdir -p ${EXPORT}
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