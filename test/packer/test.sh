#!/bin/bash

# This script requires:
#  - Packer
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

PACKER_TEMPLATE=packer_test.json

# Set variables
source ../../vars.sh

# Check if volumes are present and available
STATUS=$(openstack volume show -c status -f value ${MATLAB_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${MATLAB_VOLUME}"\' is "$STATUS"
  openstack volume show "${MATLAB_VOLUME}"
  exit 1
fi

# Pass additional scrip arguments/options through to packer build
PACKER_OPTS=$1

# Build and provision image
packer build -color=false ${PACKER_OPTS} ${PACKER_TEMPLATE}

echo "========================================================"
echo "END PACKER OUTPUT"
echo "========================================================"
echo "See output from the InSpec provisioner (above) for test results."
echo
echo "   (Note: Packer is forced to exit with a non-zero"
echo "          error code, even upon success, in order"
echo "          to prevent image creation.)"
