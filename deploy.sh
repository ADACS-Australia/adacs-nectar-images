#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - OpenStack credentials loaded in your environment

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/utils/functions.sh

# Checks
check_install openstack
check_openstack_credentials

# Set variables
IMG=$(get_image_vars_file "$@")
set -u
source ${DIR}/vars.sh

echo
echo ">>>>> Deploying image: ${IMAGE_FULLNAME} <<<<<"
echo "       (from: ${IMAGE_BUILDNAME} )"

# Check that the image to deploy is present
STATUS=$(openstack image show -c status -f value "${IMAGE_BUILDNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "active" ]; then
  echo "ERROR: The image '${IMAGE_BUILDNAME}' does not exist!"
  exit 1
fi

# Delete old image if present before deploying
STATUS=$(openstack image show -c status -f value "${IMAGE_FULLNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "WARNING: The image '${IMAGE_FULLNAME}' already exists!"
  echo "         Deleting it first..."
  openstack image delete "${IMAGE_FULLNAME}"
fi

# Deploy the new/updated image
openstack image set --name "${IMAGE_FULLNAME}" "${IMAGE_BUILDNAME}"

# Set to a community image, if required
if [ "${COMMUNITY_IMAGE}" == "yes" ]; then
  openstack image set --community "${IMAGE_FULLNAME}"
else
  openstack image set --shared "${IMAGE_FULLNAME}"
fi
