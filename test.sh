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

set -u
PACKER_TEMPLATE=packer_test.json

# Set variables
source vars.sh
echo "Testing image: ${NEW_IMAGE_NAME}"
echo "using inspec controls: ${INSPEC_CONTROLS}"

# Set some variables
export INSPEC_PROFILE="inspec/"
export INSPEC_VARSFILE="ansible/vars/conda_packages.yml"

# Build and provision image
packer build                                           \
  -color=false                                         \
  -var "inspec_profile=${INSPEC_PROFILE}"              \
  ${PACKER_TEMPLATE}

echo "========================================================"
echo "END PACKER OUTPUT"
echo "========================================================"
echo "See output from the InSpec provisioner (above) for test results."
echo
echo "   (Note: Packer is forced to exit with a non-zer oerror code, even upon success,"
echo "          in order to prevent image creation.)"
echo
