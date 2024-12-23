#!/bin/bash

# Function to display main menu
display_main_menu() {
    echo "Select the setup type:"
    echo "1. VM (host machine)"
    echo "2. LXD"
    echo "3. Docker"
    echo "4. Podman"
    echo "5. Exit"
}

# Function to handle unsupported architectures
handle_unsupported_arch() {
    echo "ARCH not supported."
    echo "1. Return back to the previous step"
    echo "2. Exit"
    read -rp "Enter your choice: " choice
    if [ "$choice" -eq 1 ]; then
        return 1
    else
        exit 0
    fi
}

# Function to handle OS selection and architecture
handle_os_and_arch() {
    local os=$1
    local version=$2
    local supported_arch=("ppc64le" "s390x" "x86_64")
    local arch=$(uname -m)

    # Check if the current architecture is supported
    for sa in "${supported_arch[@]}"; do
        if [ "$arch" == "$sa" ]; then
            if [ "$os" == "CentOS" ]; then
                # Only minimal setup is supported for CentOS
                echo "Only minimal setup is supported for $os/Almalinux $version on $arch."
                echo "Proceeding with minimal setup..."
                # Insert minimal setup script or function here
                # ./setup.sh "minimal" "${os}" "${version}"
                return 0
            elif [ "$os" == "Ubuntu" ]; then
                # Ask the user for minimal or complete setup
                while true; do
                    echo "Choose setup type for $os $version on $arch:"
                    echo "1. Minimal Setup"
                    echo "2. Complete Setup"
                    echo "3. Return back to the previous step"
                    read -rp "Enter your choice: " setup_choice

                    case $setup_choice in
                        1)
                            echo "Proceeding with minimal setup for $os $version."
                            # Insert minimal setup script or function here
                            # ./setup.sh "minimal" "${os}" "${version}"
                            return 0
                            ;;
                        2)
                            echo "Proceeding with complete setup for $os $version."
                            # Insert complete setup script or function here
                            # ./setup.sh "complete" "${os}" "${version}"
                            return 0
                            ;;
                        3)
                            return 1  # Go back to the previous menu
                            ;;
                        *)
                            echo "Invalid choice, please try again."
                            ;;
                    esac
                done
            else
                echo "Unsupported OS: $os. Please select a valid OS."
                return 1
            fi
        fi
    done

    # Handle unsupported architecture
    handle_unsupported_arch
    return $?
}

# Function to handle VM setup
setup_vm() {
    local os=$1

    if [[ "$os" == *"Ubuntu"* || "$os" == *"CentOS"* ]]; then
        echo "Selected OS: $os/Almalinux"
        echo "Select the OS version:"
        if [[ "$os" == *"Ubuntu"* ]]; then
            echo "1. 22.04"
            echo "2. 24.10"
            echo "3. 24.04"
            echo "4. Return back to main menu"
            read -rp "Enter your choice: " version_choice
            case $version_choice in
            1)
                handle_os_and_arch "$os" "22.04" || setup_vm "$os"
                ;;
            2)
                handle_os_and_arch "$os" "24.10" || setup_vm "$os"
                ;;
            3)
                handle_os_and_arch "$os" "24.04" || setup_vm "$os"
                ;;
            4)
                return
                ;;
            *)
                echo "Invalid choice."
                setup_vm "$os"
                ;;
            esac
        elif [[ "$os" == *"CentOS"* ]]; then
            echo "1. 9"
            echo "2. Return back to main menu"
            read -rp "Enter your choice: " version_choice
            case $version_choice in
            1)
                handle_os_and_arch "$os" "9" || setup_vm "$os"
                ;;
            2)
                return
                ;;
            *)
                echo "Invalid choice."
                setup_vm "$os"
                ;;
            esac
        fi

    else
        echo "OS not supported."
        echo "1. Return back to main menu"
        echo "2. Exit"
        read -rp "Enter your choice: " choice
        case "$choice" in
            1) return ;;
            2) exit 0 ;;
            *) echo "Invalid choice." ;;
        esac
    fi
}

# Helper Function: Ask OS and call setup_vm
ask_os_and_setup_vm() { 
    component="$1"
    
    case "$component" in
        "Docker" | "Podman")
            while true; do
                echo "Please select the OS for $component setup:"
                echo "1. Ubuntu"
                echo "2. CentOS/Almalinux"
                echo "3. Return back to the previous step"
                read -rp "Enter choice: " os_choice
                case $os_choice in
                    1) setup_vm "Ubuntu"; break ;;  # Pass the OS as argument to setup_vm
                    2) setup_vm "CentOS"; break ;;  # Pass the OS as argument to setup_vm
                    3) return ;;                    # Return to the previous menu
                    *)
                        echo "Invalid choice. Please try again."
                        ;;
                esac
            done
            ;;
        "LXD")
            while true; do
                echo "Please select the OS for $component setup:"
                echo "1. Ubuntu"
                echo "2. Return back to the previous step"
                read -rp "Enter choice: " os_choice
                case $os_choice in
                    1) setup_vm "Ubuntu"; break ;;  # Pass the OS as argument to setup_vm
                    2) return ;;                    # Return to the previous menu
                    *)
                        echo "Invalid choice. Please try again."
                        ;;
                esac
            done
            ;;
        *)
            echo "Unsupported component: $component"
            return ;;
    esac
}

# Function to check and install LXD
setup_lxd() {
    if ! command -v lxd &> /dev/null; then
        echo "LXD is not installed."
        echo "1. Install using snap"
        echo "2. Return back to the previous step"
        echo "3. Exit"
        read -rp "Enter your choice: " choice
        case $choice in
        1)
            sudo snap install lxd
            ;;
        2)
            return
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice."
            setup_lxd
            ;;
        esac
    fi

    ask_os_and_setup_vm "LXD"
}

# Function to check and install Docker
setup_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed."
        echo "1. Install Docker"
        echo "2. Return back to the previous step"
        echo "3. Exit"
        read -rp "Enter your choice: " choice
        case $choice in
        1)
            sudo apt update && sudo apt install -y docker.io
            ;;
        2)
            return
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice."
            setup_docker
            ;;
        esac
    fi

    ask_os_and_setup_vm "Docker"
}

# Function to check and install Podman
setup_podman() {
    if ! command -v podman &> /dev/null; then
        echo "Podman is not installed."
        echo "1. Install Podman"
        echo "2. Return back to the previous step"
        echo "3. Exit"
        read -rp "Enter your choice: " choice
        case $choice in
        1)
            sudo apt update && sudo apt install -y podman
            ;;
        2)
            return
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice."
            setup_podman
            ;;
        esac
    fi

    ask_os_and_setup_vm "Podman"
}

# Main script loop
while true; do
    display_main_menu
    read -rp "Enter your choice: " main_choice
    case $main_choice in
    1)
        setup_vm $(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
        ;;
    2)
        setup_lxd
        ;;
    3)
        setup_docker
        ;;
    4)
        setup_podman
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        ;;
    esac
done
