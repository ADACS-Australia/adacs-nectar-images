#!/bin/bash -e

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
LOGFILE=test.log

# Set variables
source vars.sh
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Testing image: ${NEW_IMAGE_NAME}"
echo

# Set some variables
export INSPEC_VARSFILE="ansible/vars/conda_packages.yml"

# Build and provision image
packer build -debug                                       \
  -color=false                                            \
  -var "inspec_profile=inspec_profiles/${INSPEC_PROFILE}" \
  ${PACKER_TEMPLATE} 2>&1 | tee ${LOGFILE}

if [ $(grep -c "Error executing Inspec" ${LOGFILE}) -ne 0 ]; then
  echo
  echo "Test FAILED for image: ${NEW_IMAGE_NAME}"
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo
  exit 1
else
  echo
  echo "Test PASSED for image: ${NEW_IMAGE_NAME}"
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  echo
  exit 0
fi
