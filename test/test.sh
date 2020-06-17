#!/bin/bash

# This script requires:
#  - Packer
#  - jq (JSON CLI tool)
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Find jq
if ! hash jq >/dev/null 2>&1; then
    echo "You need jq installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_CLOUD}" ] && [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

FILE=packer_test.json

# Get the image ID
SOURCE_IMAGE_NAME='ADACS-Astro Ubuntu 18.04 LTS (Bionic) amd64 - unreleased'
SOURCE_ID=$(openstack image show -f value -c id "$SOURCE_IMAGE_NAME")

# Define some image properties
DEFAULT_USER='ubuntu'
# OS_DISTRO='ubuntu'
# OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
BUILD_NAME='TEST_ADACS_astro_image_build'

# Volumes to attach during provisioning
MATLAB_VOLUME='matlab'

# Check if volumes are present and available
STATUS=$(openstack volume show -c status -f value ${MATLAB_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${MATLAB_VOLUME}"\' is "$STATUS"
  openstack volume show "${MATLAB_VOLUME}"
  exit 1
fi

# Fill out missing information in packer build file
cat ${FILE} | \
  jq ".variables.ssh_user           = \"${DEFAULT_USER}\""     | \
  jq ".variables.os_source_id       = \"${SOURCE_ID}\""        | \
  jq ".variables.os_build_name      = \"${BUILD_NAME}\""       | \
  jq ".variables.os_matlab_volume   = \"${MATLAB_VOLUME}\""    | \
cat > ${FILE}.tmp

# Print commands as they are run
set -x

# Pass additional scrip arguments/options through to packer build
PACKER_OPTS=$1

# Build and provision image
packer build ${PACKER_OPTS} ${FILE}.tmp
rm -f ${FILE}.tmp
set +x

echo
echo "Testing Complete."
echo "See output from the InSpec provisioner for the results."
echo
echo "   (Note: Packer is forced to exit with a non-zero"
echo "          error code, even upon success, in order"
echo "          to prevent image creation.)"
