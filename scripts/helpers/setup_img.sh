#!/bin/bash



CURRENT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
IMGDIR="${CURRENT_DIR}/../../images/${IMAGE_OS}"

# Check if /imagegeneration already exists, delete if so, and recreate
if [ -d "${image_folder}" ]; then
    echo "Directory ${image_folder} exists. Deleting and recreating it."
    sudo rm -rf "${image_folder}"
fi

sudo mkdir -p "${installer_script_folder}"
sudo chmod -R 777 "${installer_script_folder}"
sudo cp -r ${IMGDIR}/scripts/helpers/. "${helper_script_folder}"
sudo cp -r ${CURRENT_DIR}/. "${helper_script_folder}"
sudo cp ${IMGDIR}/toolsets/${toolset_file_name} "${installer_script_folder}/toolset.json"
sudo cp -r ${IMGDIR}/scripts/build/. "${installer_script_folder}"
sudo cp -r ${IMGDIR}/assets/post-gen "${image_folder}"

if [ ! -d "${image_folder}/post-generation" ]; then
    sudo mv "${image_folder}/post-gen" "${image_folder}/post-generation"
fi