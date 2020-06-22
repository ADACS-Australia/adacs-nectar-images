#!/bin/bash -e

# This script requires:
#  - Packer
#  - Ansible
#  - jq (JSON CLI tool)
#  - QEMU tools
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Find ansible
if ! hash ansible >/dev/null 2>&1; then
    echo "You need ansible installed to use this script"
    exit 1
fi

# Find jq
if ! hash jq >/dev/null 2>&1; then
    echo "You need jq installed to use this script"
    exit 1
fi

# Find qemu
if ! hash qemu-img >/dev/null 2>&1; then
    echo "You need qemu-utils installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_CLOUD}" ] && [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

FILE=packer.json

# Get the image ID
SOURCE_IMAGE_NAME='NeCTAR Ubuntu 18.04 LTS (Bionic) amd64'
SOURCE_ID=$(openstack image show -f value -c id "$SOURCE_IMAGE_NAME")

# Name to upload image as
NEW_IMAGE_NAME='ADACS-Astro Ubuntu 18.04 LTS (Bionic) amd64 - unreleased'

# Define some image properties
DEFAULT_USER='ubuntu'
OS_DISTRO='ubuntu'
OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
BUILD_NAME='ADACS_astro_image_build'

# Volumes to attach during provisioning
SOFTWARE_VOLUME='licensed_software'
MATLAB_VOLUME='matlab'

# Check if volumes are present and available
STATUS=$(openstack volume show -c status -f value ${SOFTWARE_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${SOFTWARE_VOLUME}"\' is "$STATUS"
  openstack volume show "${SOFTWARE_VOLUME}"
  exit 1
fi
STATUS=$(openstack volume show -c status -f value ${MATLAB_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${MATLAB_VOLUME}"\' is "$STATUS"
  openstack volume show "${MATLAB_VOLUME}"
  exit 1
fi

# Check if image names are not already taken/present
STATUS=$(openstack image show -c status -f value "${BUILD_NAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo The image \'"${BUILD_NAME}"\' already exists!
  exit 1
fi
STATUS=$(openstack image show -c status -f value "${NEW_IMAGE_NAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo The image \'"${NEW_IMAGE_NAME}"\' already exists!
  exit 1
fi

# Fill out missing information in packer build file
cat ${FILE} | \
  jq ".variables.ssh_user           = \"${DEFAULT_USER}\""     | \
  jq ".variables.os_source_id       = \"${SOURCE_ID}\""        | \
  jq ".variables.os_build_name      = \"${BUILD_NAME}\""       | \
  jq ".variables.os_software_volume = \"${SOFTWARE_VOLUME}\""  | \
  jq ".variables.os_matlab_volume   = \"${MATLAB_VOLUME}\""    | \
cat > ${FILE}.tmp

# Print commands as they are run
set -x

# Pass additional scrip arguments/options through to packer build
PACKER_OPTS=$1

# Build and provision image
packer build ${PACKER_OPTS} ${FILE}.tmp
rm -f ${FILE}.tmp

SAVE_DIR=${SAVE_DIR:-$(PWD)}

cd ${SAVE_DIR}

# Save image locally
openstack image save --file image_large.qcow2 ${BUILD_NAME}

# Delete image on openstack
openstack image delete ${BUILD_NAME}

# Shrink image
qemu-img convert -c -o compat=0.10 -O qcow2 image_large.qcow2 image_small.qcow2
rm image_large.qcow2

# Upload smaller image to openstack and delete local file
openstack image create --disk-format qcow2 --container-format bare --file image_small.qcow2 "${NEW_IMAGE_NAME}"
rm image_small.qcow2

# Set and unset some image properties
NEW_ID=$(openstack image show -f value -c id "$NEW_IMAGE_NAME")
openstack image set --property default_user=${DEFAULT_USER} ${NEW_ID} || true
openstack image set --property os_distro=${OS_DISTRO}       ${NEW_ID} || true
openstack image set --property os_version=${OS_VERSION}     ${NEW_ID} || true

openstack image unset --property owner_specified.openstack.sha256 ${NEW_ID} || true
openstack image unset --property owner_specified.openstack.object ${NEW_ID} || true
openstack image unset --property owner_specified.openstack.md5    ${NEW_ID} || true
