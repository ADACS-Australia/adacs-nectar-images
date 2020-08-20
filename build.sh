#!/bin/bash -e

# This script requires:
#  - Packer
#  - Ansible
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

# Find qemu
if ! hash qemu-img >/dev/null 2>&1; then
    echo "You need qemu-utils installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

PACKER_TEMPLATE=packer.json

set -u

# Set variables
source vars.sh
echo "Building image ${IMAGE_FULLNAME}"
echo "using ansible file: ${ANSIBLE_IMAGE_FILE}"

# Check if image names are not already taken/present
STATUS=$(openstack image show -c status -f value "${BUILD_NAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo The image \'"${BUILD_NAME}"\' already exists!
  exit 1
fi
STATUS=$(openstack image show -c status -f value "${IMAGE_FULLNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo The image \'"${IMAGE_FULLNAME}"\' already exists!
  exit 1
fi

# Check if volume is present and available
STATUS=$(openstack volume show -c status -f value ${SOFTWARE_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${SOFTWARE_VOLUME}"\' is "$STATUS"
  openstack volume show "${SOFTWARE_VOLUME}"
  exit 1
fi

# Print commands as they are run
set -x

# Build and provision image
packer build ${PACKER_TEMPLATE}

SAVE_DIR=${SAVE_DIR:-${PWD}}

cd ${SAVE_DIR}

# Save image locally
openstack image save --file image_large.qcow2 ${BUILD_NAME}

# Delete image on openstack
openstack image delete ${BUILD_NAME}

# Shrink image
qemu-img convert -c -o compat=0.10 -O qcow2 image_large.qcow2 image_small.qcow2
rm image_large.qcow2

# Upload smaller image to openstack and delete local file
openstack image create --disk-format qcow2 --container-format bare --file image_small.qcow2 "${IMAGE_FULLNAME}"
rm image_small.qcow2

# Allow script to continue if subsequent commands have an error
set +e

# Set and unset some image properties
openstack image set --property default_user=${DEFAULT_USER} "${IMAGE_FULLNAME}"
openstack image set --property os_distro=${OS_DISTRO}       "${IMAGE_FULLNAME}"
openstack image set --property os_version=${OS_VERSION}     "${IMAGE_FULLNAME}"

# Try unsetting these properties, in case packer set them, but don't cause error
openstack image unset --property owner_specified.openstack.sha256 "${IMAGE_FULLNAME}" || true
openstack image unset --property owner_specified.openstack.object "${IMAGE_FULLNAME}" || true
openstack image unset --property owner_specified.openstack.md5    "${IMAGE_FULLNAME}" || true
