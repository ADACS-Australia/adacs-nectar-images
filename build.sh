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
if [ -z "${OS_CLOUD}" ]; then
    echo "Please load the OpenStack credentials!"
    echo "Do:   export OS_CLOUD=<my_cloud> "
    echo "where <my_cloud> is defined in a clouds.yaml file"
    exit 1
fi

FILE=packer.json

# Get the image ID
SOURCE_IMAGE_NAME='NeCTAR Ubuntu 18.04 LTS (Bionic) amd64'
SOURCE_ID=$(openstack image show -f value -c id "$SOURCE_IMAGE_NAME")

# Name to upload image as
NEW_IMAGE_NAME='ADACS-Astro Ubuntu 18.04 LTS (Bionic) amd64'

# Define some image properties
DEFAULT_USER='ubuntu'
OS_DISTRO='ubuntu'
OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
BUILD_NAME='ADACS_astro_image_build'

# Fill out missing information in packer build file
cat ${FILE} | \
  jq ".variables.ssh_user       = \"${DEFAULT_USER}\""   | \
  jq ".builders[0].source_image = \"${SOURCE_ID}\""      | \
  jq ".builders[0].image_name   = \"${BUILD_NAME}\"" | \
cat > ${FILE}.tmp

# Print commands as they are run
set -x

# Build and provision image
packer build ${FILE}.tmp
rm -f ${FILE}.tmp

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