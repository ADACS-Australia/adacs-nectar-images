#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - Packer
#  - Ansible
#  - OpenStack credentials loaded in your environment

# Inputs:
#  - IMG_VARS

# Check if required software to run script is installed.
for ITEM in openstack packer ansible; do
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

echo
echo ">>>>> Building image: ${IMAGE_BUILDNAME} <<<<<"

# Check if build name is not already taken/present
STATUS=$(openstack image show -c status -f value "${IMAGE_BUILDNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "WARNING: The image '${IMAGE_BUILDNAME}' already exists!"
  echo "         Deleting it first..."
  openstack image delete ${IMAGE_BUILDNAME}
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

# Set and unset some image properties
openstack image set --property default_user=${DEFAULT_USER} "${IMAGE_BUILDNAME}"
openstack image set --property os_distro=${OS_DISTRO}       "${IMAGE_BUILDNAME}"
openstack image set --property os_version=${OS_VERSION}     "${IMAGE_BUILDNAME}"

# Try unsetting these properties, in case packer set them, but don't raise error
openstack image unset --property owner_specified.openstack.sha256 "${IMAGE_BUILDNAME}" || true
openstack image unset --property owner_specified.openstack.object "${IMAGE_BUILDNAME}" || true
openstack image unset --property owner_specified.openstack.md5    "${IMAGE_BUILDNAME}" || true
