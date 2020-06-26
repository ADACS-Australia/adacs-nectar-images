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
source vars.sh

# Check if volumes are present and available
STATUS=$(openstack volume show -c status -f value ${MATLAB_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${MATLAB_VOLUME}"\' is "$STATUS"
  openstack volume show "${MATLAB_VOLUME}"
  exit 1
fi

# Pass additional scrip arguments/options through to packer build
PACKER_OPTS=$1

# Set some directories
VARS_DIR="ansible/vars/"
INSPEC_DIR="inspec/"

# Build and provision image
packer build                                           \
  -color=false                                         \
  -var "inspec_profile=${INSPEC_DIR}"                  \
  -var "apt_packages=${VARS_DIR}/apt_packages.yml"     \
  -var "conda_packages=${VARS_DIR}/conda_packages.yml" \
  ${PACKER_OPTS} ${PACKER_TEMPLATE}

echo "========================================================"
echo "END PACKER OUTPUT"
echo "========================================================"
echo "See output from the InSpec provisioner (above) for test results."
echo
echo "   (Note: Packer is forced to exit with a non-zer oerror code, even upon success,"
echo "          in order to prevent image creation.)"
echo
