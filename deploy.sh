#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - OpenStack credentials loaded in your environment

# Inputs:
#  - IMG_VARS

# Check if required software to run script is installed.
for ITEM in openstack; do
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
echo
echo ">>>>> Deploying image: ${IMAGE_FULLNAME} <<<<<"
echo "       (from: ${STAGED_NAME} )"

# Check that staged image is present
STATUS=$(openstack image show -c status -f value "${STAGED_IMAGE}" 2> /dev/null || true)
if [ "${STATUS}" != "active" ]; then
  echo "ERROR: The image '${STAGED_NAME}' does not exist!"
  exit 1
fi

# Check that image name for deploy is not already taken/present
STATUS=$(openstack image show -c status -f value "${IMAGE_FULLNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "ERROR: The image '${IMAGE_FULLNAME}' already exists!"
  exit 1
fi

# Finally change the name (if everything was successfuly)
openstack image set --name "${IMAGE_FULLNAME}" "${STAGED_NAME}"

# Set to community image if required
if [ "${COMMUNITY_IMAGE}" == "yes" ]; do
  openstack image set --community "${IMAGE_FULLNAME}"
fi
