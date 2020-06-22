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
if [ -z "${OS_CLOUD}" ] && [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

PACKER_TEMPLATE=packer.json

# Set variables
source vars.sh

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

# Print commands as they are run
set -x

# Pass additional scrip arguments/options through to packer build
PACKER_OPTS=$1

# Build and provision image
packer build ${PACKER_OPTS} ${PACKER_TEMPLATE}

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

# Allow script to continue if subsequent commands have an error
set +e

# Set and unset some image properties
NEW_ID=$(openstack image show -f value -c id "$NEW_IMAGE_NAME")
openstack image set --property default_user=${DEFAULT_USER} ${NEW_ID}
openstack image set --property os_distro=${OS_DISTRO}       ${NEW_ID}
openstack image set --property os_version=${OS_VERSION}     ${NEW_ID}

openstack image unset --property owner_specified.openstack.sha256 ${NEW_ID}
openstack image unset --property owner_specified.openstack.object ${NEW_ID}
openstack image unset --property owner_specified.openstack.md5    ${NEW_ID}
