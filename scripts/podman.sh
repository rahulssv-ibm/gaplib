#!/bin/bash

# Function to ensure Podman is installed and available
ensure_podman() {
    if ! command -v podman &> /dev/null; then
        echo "Podman is not installed. Attempting to install Podman..."
        if sudo sh -c "${SRCDIR}/../images/${HOST_OS_NAME}/scripts/build/install-podman.sh"; then
            echo "Podman installed successfully."
        else
            echo "Failed to install Podman. Please check your system configuration." >&2
            exit 1
        fi
    else
        echo "Podman is already installed. Version: $(podman --version)"
    fi
}

# Function to build a Podman image
build_image() {
    local dockerfile="${SRCDIR}/../dockerfiles/Dockerfile.${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}"

    if [ ! -f "$dockerfile" ]; then
        echo "Error: Dockerfile for ${CONTAINER_OS_NAME} version ${CONTAINER_OS_VERSION} not found." >&2
        return 1
    fi
    PATCH_FILE="${PATCH_FILE:-runner-main-sdk8-${ARCH}.patch}"
    echo "Building Podman image for ${CONTAINER_OS_NAME} version ${CONTAINER_OS_VERSION}..."
    podman build -f "$dockerfile" \
        --build-arg RUNNERPATCH=${SRCDIR}/../patches/${PATCH_FILE} \
        --build-arg ARCH="${ARCH}" \
        --tag "runner:${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}" .

    if [ $? -eq 0 ]; then
        echo "Podman image built successfully: runner:${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}"
    else
        echo "Error: Failed to build Podman image." >&2
        return 1
    fi
}

# Main function to run the script
run() {
    # Export system architecture
    export ARCH=$(uname -m)
    export HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]' | awk '{print $1}')
    export HOST_OS_VERSION=$(cat /etc/os-release | grep -E 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')

    # Validate input arguments and set defaults
    export CONTAINER_OS_NAME="${1:-ubuntu}"
    export CONTAINER_OS_VERSION="${2:-latest}"

    export SOURCE=$(readlink -f "${BASH_SOURCE[0]}")
    export SRCDIR=$(dirname "${SOURCE}")

    echo "Host OS: ${HOST_OS_NAME} ${HOST_OS_VERSION}, Architecture: ${ARCH}"
    echo "Target container OS: ${CONTAINER_OS_NAME} ${CONTAINER_OS_VERSION}"

    # Ensure Podman is installed
    ensure_podman "$@"

    # Build the Podman image
    build_image "$@"
    return $?
}

# Execute the main function
run "$@"
RC=$?

# Exit with the return code of the main function
exit ${RC}
