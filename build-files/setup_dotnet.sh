#!/bin/bash

header() {
    TS=`date +"%Y-%m-%dT%H:%M:%S%:z"`
    echo "${TS} +--------------------------------------------+"
    echo "${TS} | $*"
    echo "${TS} +--------------------------------------------+"
    echo
}

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

update_fresh_container() {
    header "Upgrading and installing packages"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update -y >/dev/null
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install dotnet-sdk-8.0 make \
        gcc g++ autoconf automake m4 libtool -y >/dev/null

    if [ $? -ne 0 ]; then
        exit 32
    fi
    sudo apt autoclean

    msg "Initializing LXD environment"
    sudo lxd init --preseed </tmp/lxd-preseed.yaml

    msg "Make sure we have lxd authority"
    sudo usermod -G lxd -a ubuntu
}

setup_dotnet_sdk() {
    SDK_VERSION=`dotnet --version`
    msg "Using SDK - ${SDK_VERSION}"

    # fix ownership
    sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc

    sudo chmod +x /etc/rc.local
    sudo systemctl start rc-local

    return 0
}

run() {
    update_fresh_container
    setup_dotnet_sdk
    return ${RC}
}

run "$@"
exit $?

