#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - Packer
#  - Ansible
#  - OpenStack credentials loaded in your environment

# Inputs:
#  - IMG

# Check if required software to run script is installed.
for ITEM in openstack packer ansible; do
  if ! hash ${ITEM} >/dev/null 2>&1; then
      echo "You need ${ITEM} installed to use this script"
      exit 1
  fi
done

# Check if OpenStack credentials are loaded
openstack quota show > /dev/null
if [ $? -ne 0 ]; then
    echo "--- Please load the OpenStack credentials! ---"
    echo "    (source your OpenStack RC file)"
    exit 1
fi

# Set variables
set -u
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

# Build and provision image
packer build ${PACKER_TEMPLATE}

# Try unsetting these properties, in case packer set them, but don't raise error
for PROPERTY in base_image_ref      \
                boot_roles          \
                image_location      \
                image_state         \
                image_type          \
                murano_image_info   \
                os_hash_algo        \
                os_hash_value       \
                os_hidden           \
                owner_project_name  \
                owner_user_name     \
                stores              \
                user_id             \
                owner_specified.openstack.sha256 \
                owner_specified.openstack.object \
                owner_specified.openstack.md5
  do
    openstack image unset --property $PROPERTY "${IMAGE_BUILDNAME}" || true
done
