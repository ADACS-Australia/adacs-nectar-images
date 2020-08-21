#!/bin/bash -ea

# This script requires:
#  - Packer
#  - Inspec
#  - OpenStack credentials loaded in your environment

# Inputs:
#  - IMG_VARS

# Check if required software to run script is installed.
for ITEM in packer inspec; do
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
PACKER_TEMPLATE=packer_test.json
LOGFILE=test.log
export INSPEC_VARSFILE="ansible/vars/conda_packages.yml"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Testing image: ${TEST_IMAGE}"
echo

# Check that build image is present
STATUS=$(openstack image show -c status -f value "${TEST_IMAGE}" 2> /dev/null || true)
if [ "${STATUS}" != "active" ]; then
  echo "ERROR: The image '${TEST_IMAGE}' does not exist!"
  exit 1
fi

# Build and provision image
packer build                                              \
  -color=false                                            \
  -var "inspec_profile=inspec_profiles/${INSPEC_PROFILE}" \
  ${PACKER_TEMPLATE} 2>&1 | tee ${LOGFILE}

if [ $(grep -c "SUCCESS: TESTS PASSED" ${LOGFILE}) -gt 0 ]; then
  TEST_OUTCOME='PASSED'
  EXIT_CODE=0
else
  TEST_OUTCOME='FAILED'
  EXIT_CODE=1
fi

echo
echo "Test ${TEST_OUTCOME} for image: ${TEST_IMAGE}"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo
exit ${EXIT_CODE}
