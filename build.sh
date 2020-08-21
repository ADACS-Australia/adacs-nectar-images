#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - Packer
#  - Ansible
#  - QEMU uitls
#  - OpenStack credentials loaded in your environment

# Inputs:
#  - IMG_VARS
#  - SAVE_DIR (optional)

# Check if required software to run script is installed.
for ITEM in openstack packer ansible qemu-img; do
  if ! hash ${ITEM} >/dev/null 2>&1; then
      echo "You need ${ITEM} installed to use this script"
      exit 1
  fi
done

# Check if OpenStack credentials are loaded
if [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

# Set variables
set -u
source $IMG_VARS
source vars.sh
PACKER_TEMPLATE=packer.json
SAVE_DIR=${SAVE_DIR:-${PWD}}

echo
echo ">>>>> Building image: ${PACKER_BUILD_NAME} <<<<<"

# Check if image name is not already taken/present
STATUS=$(openstack image show -c status -f value "${PACKER_BUILD_NAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "ERROR: The image '${PACKER_BUILD_NAME}' already exists!"
  exit 1
fi

# Check if volume is present and available
STATUS=$(openstack volume show -c status -f value ${SOFTWARE_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo "ERROR: The volume '${SOFTWARE_VOLUME}' is $STATUS"
  openstack volume show "${SOFTWARE_VOLUME}"
  exit 1
fi

# Print commands as they are run
set -x

# Build and provision image
packer build ${PACKER_TEMPLATE}

# Change to save directory, if given
cd ${SAVE_DIR}

# Save image locally
openstack image save --file image_large.qcow2 ${PACKER_BUILD_NAME}

# Delete image on openstack
openstack image delete ${PACKER_BUILD_NAME}

# Shrink image
qemu-img convert -c -o compat=0.10 -O qcow2 image_large.qcow2 image_small.qcow2
rm image_large.qcow2

# Upload smaller image to openstack and delete local file
openstack image create --disk-format qcow2 --container-format bare --file image_small.qcow2 "${STAGED_NAME}"
rm image_small.qcow2

# Set and unset some image properties
openstack image set --property default_user=${DEFAULT_USER} "${STAGED_NAME}"
openstack image set --property os_distro=${OS_DISTRO}       "${STAGED_NAME}"
openstack image set --property os_version=${OS_VERSION}     "${STAGED_NAME}"

# Try unsetting these properties, in case packer set them, but don't raise error
openstack image unset --property owner_specified.openstack.sha256 "${STAGED_NAME}" || true
openstack image unset --property owner_specified.openstack.object "${STAGED_NAME}" || true
openstack image unset --property owner_specified.openstack.md5    "${STAGED_NAME}" || true
