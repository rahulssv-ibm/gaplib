# GapLib Setup Scripts

This repository contains a set of setup scripts to configure various environments for your project, including VM (host machine), LXD, Docker, and Podman. The scripts are designed to work with different operating systems and architecture types, allowing for a flexible setup tailored to your needs.

## **Table of Contents**

- [Overview](#overview)
- [Scripts](#scripts)
  - [run.sh](#runsh)
  - [Other Scripts](#other-scripts)
- [Usage](#usage)
- [Setup Options](#setup-options)
  - [Main Menu](#main-menu)
  - [OS and Version Selection](#os-and-version-selection)
  - [Minimal or Complete Setup](#minimal-or-complete-setup)
  - [Unsupported Architectures](#unsupported-architectures)
- [Requirements](#requirements)
- [Contributing](#contributing)

## **Overview**

The GapLib setup scripts help automate the setup of various environments, making it easier for users to get started quickly. The scripts cover different Linux distributions (like Ubuntu and CentOS/Almalinux) and offer both minimal and complete setup options based on the user's requirements.

### **Supported Environments**
- **VM (host machine)**: Sets up the environment directly on a virtual machine or host machine.
- **LXD**: A container-based virtualization system.
- **Docker**: A popular platform for developing, shipping, and running applications inside containers.
- **Podman**: An alternative to Docker that is daemonless and can manage containers.

### **Supported Architectures**
- **ppc64le**
- **s390x**
- **x86_64**

### **Supported Operating Systems**
- **Ubuntu** (Versions 22.04, 24.10, 24.04)
- **CentOS** (Version 9)

## **Scripts**

### **run.sh**

`run.sh` is the main entry point for setting up your environment. The script presents an interactive menu that allows users to select the setup type based on their preference (VM, LXD, Docker, or Podman). It then guides the user through the process of choosing the appropriate OS, version, and setup type (minimal or complete). 

#### **Key Features**
- **Interactive Menu**: Allows users to select setup type (VM, LXD, Docker, Podman).
- **Architecture Handling**: Ensures compatibility with supported architectures (ppc64le, s390x, x86_64).
- **OS and Version Selection**: Lets users select the OS and version for setup (Ubuntu or CentOS).
- **Setup Type Options**: Provides choices for minimal or complete setup based on the selected environment and OS.

## **Usage**

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/rahulssv-ibm/gaplib.git
   cd gaplib
   ```

2. Run the `run.sh` script:

   ```bash
   bash run.sh
   ```

3. Follow the interactive menu prompts to select your environment type (VM, LXD, Docker, or Podman), choose your OS, version, and setup type (minimal or complete).

## **Setup Options**

### **Main Menu**

The script will display the following options for setup:

```
1. VM (host machine)
2. LXD
3. Docker
4. Podman
5. Exit
```

Select the appropriate option to proceed with the setup.

### **OS and Version Selection**

For each environment setup, the script will prompt you to select the operating system (Ubuntu or CentOS) and the version. If no version is specified, it will prompt for the version choice.

### **Minimal or Complete Setup**

Based on your environment, you will be prompted to choose between:
- **Minimal Setup**: Only essential configurations are applied.
- **Complete Setup**: Full setup including additional configurations.

### **Unsupported Architectures**

If the script detects an unsupported architecture, you will be prompted with the following options:

```
1. Return back to the previous step
2. Exit
```

### **Requirements**

The script requires `bash` and may need `sudo` privileges depending on the environment setup.


## **Contributing**

We welcome contributions to improve these setup scripts. Feel free to fork this repository, create a branch, and submit a pull request with your changes.
