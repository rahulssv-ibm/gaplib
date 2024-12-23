#!/bin/bash

# Function to ensure Docker is installed and available
ensure_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Attempting to install Docker..."
        if sudo sh -c "install-docker.sh"; then
            echo "Docker installed successfully."
        else
            echo "Failed to install Docker. Please check your system configuration." >&2
            exit 1
        fi
    else
        echo "Docker is already installed. Version: $(docker --version)"
    fi
}

# Function to build a Docker image
build_image() {
    local dockerfile="Dockerfile.${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}"

    if [ ! -f "$dockerfile" ]; then
        echo "Error: Dockerfile for ${CONTAINER_OS_NAME} version ${CONTAINER_OS_VERSION} not found." >&2
        return 1
    fi

    echo "Building Docker image for ${CONTAINER_OS_NAME} version ${CONTAINER_OS_VERSION}..."
    docker build -f "$dockerfile" \
        --build-arg RUNNERPATCH=build-files/runner-sdk-8.patch \
        --build-arg ARCH="${ARCH}" \
        --tag "runner:${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}" .

    if [ $? -eq 0 ]; then
        echo "Docker image built successfully: runner:${CONTAINER_OS_NAME}.${CONTAINER_OS_VERSION}"
    else
        echo "Error: Failed to build Docker image." >&2
        return 1
    fi
}

# Main function to run the script
run() {
    # Export system architecture
    export ARCH=$(uname -m)
    export HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
    export HOST_OS_VERSION=$(grep -E '^VERSION_ID' /etc/os-release | cut -d'=' -f2 | tr -d '"')

    # Validate input arguments and set defaults
    export CONTAINER_OS_NAME="${1:-ubuntu}"
    export CONTAINER_OS_VERSION="${2:-latest}"

    echo "Host OS: ${HOST_OS_NAME} ${HOST_OS_VERSION}, Architecture: ${ARCH}"
    echo "Target container OS: ${CONTAINER_OS_NAME} ${CONTAINER_OS_VERSION}"

    # Ensure Docker is installed
    ensure_docker

    # Build the Docker image
    build_image "$@"
    return $?
}

# Execute the main function
run "$@"
RC=$?

# Exit with the return code of the main function
exit ${RC}
