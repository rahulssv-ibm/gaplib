#!/bin/bash

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

if [[ "$ARCH" == "ppc64le" ]]; then 
    # sudo apt update
    # sudo apt install -y libssl-dev libicu-dev libcurl4 zlib1g
    # sudo apt install -y tar unzip

    # unzip /imagegeneration/installers/output_8.0.100.zip -d /tmp
    # cp -r /tmp/output_8.0.100/. /opt/dotnet

    # mkdir -p ~/dotnet
    # cd ~/dotnet
    # find /opt/dotnet -name "*.tar.gz" -exec tar -xvf {} -C ~/dotnet \;
    # mkdir -p ~/dotnet/nupkg
    # find /opt/dotnet -name "*.nupkg" -exec unzip {} -d ~/dotnet/nupkg \;
    # echo 'export PATH=$HOME/dotnet:$PATH' >> ~/.bashrc
    # source ~/.bashrc
    # sudo ln -s $HOME/dotnet/dotnet /usr/local/bin/dotnet
    # dotnet --version
    sudo apt update
    sudo apt install -y libssl-dev libicu-dev libcurl4 zlib1g
    sudo apt install -y tar unzip
    # unzip /imagegeneration/installers/output_8.0.100.zip -d /tmp
    # cp -r /tmp/output_8.0.100/. /opt/dotnet
    mkdir /opt/dotnet
    cp -r  /imagegeneration/installers/dotnet-sdk-8.0.112-ubuntu.24.04-ppc64le.tar.gz /opt/dotnet/.
    cd /opt/dotnet
    mkdir .dotnet
    find /opt/dotnet -name "*.tar.gz" -exec tar -xvf {} -C .dotnet \; 
    set_etc_environment_variable DOTNET_ROOT /opt/dotnet/.dotnet
    set_etc_environment_variable DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1
    set_etc_environment_variable DOTNET_NOLOGO 1
    set_etc_environment_variable DOTNET_MULTILEVEL_LOOKUP 0
    prepend_etc_environment_path '/opt/dotnet/.dotnet'
    prepend_etc_environment_path '/opt/dotnet/.dotnet/tools'
    ln -s /opt/dotnet/.dotnet/dotnet /usr/local/bin/dotnet
    dotnet --version
    # apt update
    # apt install unzip -y

    # unzip /imagegeneration/installers/output_8.0.100.zip -d /tmp
    # cp -r /tmp/output_8.0.100/. /opt/dotnet
    # mkdir -p /usr/local/bin/dotnet
    # find /opt/dotnet -name "*.tar.gz" -exec tar -xvf {} -C /usr/local/bin/dotnet \;
    # mkdir -p /usr/local/bin/dotnet/nupkg
    # find /opt/dotnet -name "*.nupkg" -exec unzip {} -d /usr/local/bin/dotnet/nupkg \;
    # export PATH=$PATH:/usr/local/bin/dotnet
    # echo "export PATH=$PATH:/usr/local/bin/dotnet" >> ~/.bashrc
    # source ~/.bashrc
    # dotnet --version
    # Install .NET
    # echo "Upgrading and installing packages"
    # sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update -y
    # sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install alien -y
    
    # if [ $? -ne 0 ]; then
    #     exit 32
    # fi
    # sudo apt autoclean

    # sudo sed "s/--no-absolute-filenames//" /usr/share/perl5/Alien/Package/Rpm.pm > /tmp/Rpm.pm
    # sudo cp /tmp/Rpm.pm /usr/share/perl5/Alien/Package/Rpm.pm

    # MIRROR="https://mirror.lchs.network/pub/almalinux/9.4/AppStream/${ARCH}/os/Packages"
    
    # PKGS=(
    #     "dotnet-host-8.0.10-1.el9_4"
    #     "dotnet-apphost-pack-8.0-8.0.10-1.el9_4"
    #     "dotnet-hostfxr-8.0-8.0.10-1.el9_4"
    #     "dotnet-targeting-pack-8.0-8.0.10-1.el9_4"
    #     "dotnet-templates-8.0-8.0.110-1.el9_4"
    #     "dotnet-runtime-8.0-8.0.10-1.el9_4"
    #     "dotnet-runtime-dbg-8.0-8.0.10-1.el9_4"
    #     "dotnet-sdk-8.0-8.0.110-1.el9_4"
    #     "dotnet-sdk-dbg-8.0-8.0.110-1.el9_4"
    #     "aspnetcore-runtime-8.0-8.0.10-1.el9_4"
    #     "aspnetcore-targeting-pack-8.0-8.0.10-1.el9_4"
    # )
    
    # echo "Retrieving .NET packages..."
    # pushd /tmp >/dev/null 
    
    # for pkg in "${PKGS[@]}"; do
    #     RPM="${pkg}.${ARCH}.rpm"
    #     wget -q ${MIRROR}/${RPM}
    #     echo -n "Converting ${RPM}... "
    #     sudo alien -d ${RPM} |& grep -v ^warning
    #     if [ $? -ne 0 ]; then
    #         return 2
    #     fi
    #     rm -f ${RPM}
    # done

    # echo "Installing dotnet"
    # sudo DEBIAN_FRONTEND=noninteractive dpkg --install /tmp/*.deb
    # if [ $? -ne 0 ]; then
    #     return 3
    # fi
    # sudo rm -f /tmp/*.deb
    # popd >/dev/null

    # echo "Creating symbolic links for architecture ${ARCH}..."
    # pushd /usr/lib64/dotnet/packs >/dev/null 
    # sudo ln -sf Microsoft.AspNetCore.App.Ref Microsoft.AspNetCore.App.Runtime.linux-"${ARCH}"
    # sudo ln -sf Microsoft.AspNetCore.App.Ref Microsoft.AspNetCore.App.linux-"${ARCH}"
    # sudo ln -sf Microsoft.NETCore.App.Host.rhel.9-"${ARCH}" Microsoft.NETCore.App.Host.linux-"${ARCH}"
    # sudo ln -sf Microsoft.NETCore.App.Ref Microsoft.NETCore.App.Runtime.linux-"${ARCH}"
    # popd >/dev/null

    # echo "Using SDK version: $(dotnet --version)"
elif [[ "$ARCH" == "s390x" ]]; then
    echo "Installing dotnet for architecture: $ARCH"
    apt-get install -y dotnet-sdk-8.0
else
    sudo apt update
    sudo apt install -y libssl-dev libicu-dev libcurl4 zlib1g
    sudo apt install -y tar unzip
    # unzip /imagegeneration/installers/output_8.0.100.zip -d /tmp
    # cp -r /tmp/output_8.0.100/. /opt/dotnet
    mkdir /opt/dotnet
    cp -r  /imagegeneration/installers/dotnet-sdk-8.0.112-ubuntu.24.04-x64.tar.gz /opt/dotnet/.
    cd /opt/dotnet
    mkdir .dotnet
    find /opt/dotnet -name "*.tar.gz" -exec tar -xvf {} -C .dotnet \; 
    set_etc_environment_variable DOTNET_ROOT /opt/dotnet/.dotnet
    set_etc_environment_variable DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1
    set_etc_environment_variable DOTNET_NOLOGO 1
    set_etc_environment_variable DOTNET_MULTILEVEL_LOOKUP 0
    prepend_etc_environment_path '/opt/dotnet/.dotnet'
    prepend_etc_environment_path '/opt/dotnet/.dotnet/tools'
    ln -s /opt/dotnet/.dotnet/dotnet /usr/local/bin/dotnet
    dotnet --version
#     extract_dotnet_sdk() {
#         local archive_name=$1

#         set -e
#         destination="./tmp-$(basename -s .tar.gz $archive_name)"

#         echo "Extracting $archive_name to $destination"
#         mkdir "$destination" && tar -C "$destination" -xzf "$archive_name"
#         rsync -qav --remove-source-files "$destination/shared/" /usr/share/dotnet/shared/
#         rsync -qav --remove-source-files "$destination/host/" /usr/share/dotnet/host/
#         rsync -qav --remove-source-files "$destination/sdk/" /usr/share/dotnet/sdk/
#         rm -rf "$destination" "$archive_name"
#     }

#     # Ubuntu 20 doesn't support EOL versions
#     latest_dotnet_packages=$(get_toolset_value '.dotnet.aptPackages[]')
#     dotnet_versions=$(get_toolset_value '.dotnet.versions[]')
#     dotnet_tools=$(get_toolset_value '.dotnet.tools[].name')

#     # Disable telemetry
#     export DOTNET_CLI_TELEMETRY_OPTOUT=1

#     # Install .NET SDK from apt
#     # There is a versions conflict, that leads to
#     # Microsoft <-> Canonical repos dependencies mix up.
#     # Give Microsoft's repo higher priority to avoid collisions.
#     # See: https://github.com/dotnet/core/issues/7699
#     cat <<EOF > /etc/apt/preferences.d/dotnet
# Package: *net*
# Pin: origin packages.microsoft.com
# Pin-Priority: 1001
# EOF

#     apt-get update

#     for latest_package in ${latest_dotnet_packages[@]}; do
#         echo "Determining if .NET Core ($latest_package) is installed"
#         if ! dpkg -S $latest_package &> /dev/null; then
#             echo "Could not find .NET Core ($latest_package), installing..."
#             apt-get install -y $latest_package
#         else
#             echo ".NET Core ($latest_package) is already installed"
#         fi
#     done

#     rm /etc/apt/preferences.d/dotnet

#     apt-get update

#     # Install .NET SDK from home repository
#     # Get list of all released SDKs from channels which are not end-of-life or preview
#     sdks=()
#     for version in ${dotnet_versions[@]}; do
#         release_url="https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/${version}/releases.json"
#         releases=$(cat "$(download_with_retry "$release_url")")
#         if [[ $version == "6.0" ]]; then
#             sdks=("${sdks[@]}" $(echo "${releases}" | jq -r 'first(.releases[].sdks[]?.version | select(contains("preview") or contains("rc") | not))'))
#         else
#             sdks=("${sdks[@]}" $(echo "${releases}" | jq -r '.releases[].sdk.version | select(contains("preview") or contains("rc") | not)'))
#             sdks=("${sdks[@]}" $(echo "${releases}" | jq -r '.releases[].sdks[]?.version | select(contains("preview") or contains("rc") | not)'))
#         fi
#     done

#     sorted_sdks=$(echo ${sdks[@]} | tr ' ' '\n' | sort -r | uniq -w 5)

#     # Download/install additional SDKs in parallel
#     export -f download_with_retry
#     export -f extract_dotnet_sdk

#     parallel --jobs 0 --halt soon,fail=1 \
#         'url="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/{}/dotnet-sdk-{}-linux-x64.tar.gz"; \
#         download_with_retry $url' ::: "${sorted_sdks[@]}"

#     find . -name "*.tar.gz" | parallel --halt soon,fail=1 'extract_dotnet_sdk {}'

#     # NuGetFallbackFolder at /usr/share/dotnet/sdk/NuGetFallbackFolder is warmed up by smoke test
#     # Additional FTE will just copy to ~/.dotnet/NuGet which provides no benefit on a fungible machine
#     set_etc_environment_variable DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1
#     set_etc_environment_variable DOTNET_NOLOGO 1
#     set_etc_environment_variable DOTNET_MULTILEVEL_LOOKUP 0
#     prepend_etc_environment_path '$HOME/.dotnet/tools'

#     # Install .Net tools
#     for dotnet_tool in ${dotnet_tools[@]}; do
#         echo "Installing dotnet tool $dotnet_tool"
#         dotnet tool install $dotnet_tool --tool-path '/etc/skel/.dotnet/tools'
#     done
fi
