toolset_file_name = "toolset-2204.json"

image_folder            = "/imagegeneration"
helper_script_folder    = "/imagegeneration/helpers"
installer_script_folder = "/imagegeneration/installers"
imagedata_file          = "/imagegeneration/imagedata.json"

mkdir ${local.image_folder}
chmod 777 ${local.image_folder}

msg "Copy the patch file into gha-builder"
lxc file push ${BUILD_PREREQS_PATH}/scripts/helpers"${BUILD_CONTAINER}${BUILD_HOME}/${local.helper_script_folder}"

# Add apt wrapper to implement retries
sudo sh -c '/scripts/build/configure-apt-mock.sh"'
msg "Setting user ubuntu with sudo privileges"
lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- sh -c "/scripts/build/configure-apt-mock.sh"

HELPER_SCRIPTS=${local.helper_script_folder}
DEBIAN_FRONTEND=noninteractive

# Install MS package repos, Configure apt
sudo sh -c '${HELPER_SCRIPTS} ${DEBIAN_FRONTEND} ${path.root}/../scripts/build/install-ms-repos.sh ${path.root}/../scripts/build/configure-apt.sh'

# Configure limits
sudo sh -c '${HELPER_SCRIPTS} ${DEBIAN_FRONTEND} ${path.root}/../scripts/build/configure-limits.sh'


lxc file push ${BUILD_PREREQS_PATH}/scripts/build"${BUILD_CONTAINER}${BUILD_HOME}/${local.installer_script_folder}"

lxc file push ${BUILD_PREREQS_PATH}/assets/post-gen"${BUILD_CONTAINER}${BUILD_HOME}/${local.image_folder}"

lxc file push ${BUILD_PREREQS_PATH}/toolsets/${local.toolset_file_name} "${BUILD_CONTAINER}${BUILD_HOME}/${local.installer_script_folder}/toolset.json"

mv ${local.image_folder}/post-gen ${local.image_folder}/post-generation

DEBIAN_FRONTEND HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/install-apt-vital.sh

DEBIAN_FRONTEND HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/install-powershell.sh

HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/Install-PowerShellModules.ps1

DEBIAN_FRONTEND HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER 
      "${path.root}/../scripts/build/install-actions-cache.sh",
      "${path.root}/../scripts/build/install-runner-package.sh",
      "${path.root}/../scripts/build/install-apt-common.sh",
      "${path.root}/../scripts/build/install-azcopy.sh",
      "${path.root}/../scripts/build/install-azure-cli.sh",
      "${path.root}/../scripts/build/install-azure-devops-cli.sh",
      "${path.root}/../scripts/build/install-bicep.sh",
      "${path.root}/../scripts/build/install-apache.sh",
      "${path.root}/../scripts/build/install-aws-tools.sh",
      "${path.root}/../scripts/build/install-clang.sh",
      "${path.root}/../scripts/build/install-swift.sh",
      "${path.root}/../scripts/build/install-cmake.sh",
      "${path.root}/../scripts/build/install-codeql-bundle.sh",
      "${path.root}/../scripts/build/install-container-tools.sh",
      "${path.root}/../scripts/build/install-dotnetcore-sdk.sh",
      "${path.root}/../scripts/build/install-microsoft-edge.sh",
      "${path.root}/../scripts/build/install-gcc-compilers.sh",
      "${path.root}/../scripts/build/install-firefox.sh",
      "${path.root}/../scripts/build/install-gfortran.sh",
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      "${path.root}/../scripts/build/install-google-chrome.sh",
      "${path.root}/../scripts/build/install-google-cloud-cli.sh",
      "${path.root}/../scripts/build/install-haskell.sh",
      "${path.root}/../scripts/build/install-java-tools.sh",
      "${path.root}/../scripts/build/install-kubernetes-tools.sh",
      "${path.root}/../scripts/build/install-miniconda.sh",
      "${path.root}/../scripts/build/install-kotlin.sh",
      "${path.root}/../scripts/build/install-mysql.sh",
      "${path.root}/../scripts/build/install-nginx.sh",
      "${path.root}/../scripts/build/install-nvm.sh",
      "${path.root}/../scripts/build/install-nodejs.sh",
      "${path.root}/../scripts/build/install-bazel.sh",
      "${path.root}/../scripts/build/install-php.sh",
      "${path.root}/../scripts/build/install-postgresql.sh",
      "${path.root}/../scripts/build/install-pulumi.sh",
      "${path.root}/../scripts/build/install-ruby.sh",
      "${path.root}/../scripts/build/install-rust.sh",
      "${path.root}/../scripts/build/install-julia.sh",
      "${path.root}/../scripts/build/install-selenium.sh",
      "${path.root}/../scripts/build/install-packer.sh",
      "${path.root}/../scripts/build/install-vcpkg.sh",
      "${path.root}/../scripts/build/configure-dpkg.sh",
      "${path.root}/../scripts/build/install-yq.sh",
      "${path.root}/../scripts/build/install-android-sdk.sh",
      "${path.root}/../scripts/build/install-pypy.sh",
      "${path.root}/../scripts/build/install-python.sh",
      "${path.root}/../scripts/build/install-zstd.sh"

HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER DOCKERHUB_PULL_IMAGES=NO ${path.root}/../scripts/build/install-docker.sh

HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/install-pipx-packages.sh

DEBIAN_FRONTEND HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/install-homebrew.sh

HELPER_SCRIPTS ${path.root}/../scripts/build/configure-snap.sh

echo 'Reboot VM'
sudo reboot

pause_before        = "1m0s"
${path.root}/../scripts/build/cleanup.sh
start_retry_timeout = "10m"

HELPER_SCRIPTS INSTALLER_SCRIPT_FOLDER ${path.root}/../scripts/build/configure-system.sh

sleep 30
/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync