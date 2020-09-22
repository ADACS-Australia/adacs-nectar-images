#!/bin/bash -ea

# This script requires:
#  - Packer
#  - Inspec
#  - OpenStack credentials loaded in your environment

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/../utils/functions.sh

# Checks
check_install packer inspec
check_openstack_credentials

# Set variables
IMG=$(get_image_vars_file "$@")
set -u
source ${DIR}/../vars.sh
PACKER_TEMPLATE=${DIR}/packer_test.json
TEST_LOG=${DIR}/test.log
INSPEC_PROFILE=${DIR}/inspec_profiles/${IMAGE_TAGNAME}
INSPEC_VARSFILE="${DIR}/../build/ansible/vars/conda_packages.yml"

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
packer build                              \
  -color=false                            \
  -var "inspec_profile=${INSPEC_PROFILE}" \
  ${PACKER_TEMPLATE} 2>&1 | tee ${TEST_LOG}

if [ $(grep -c "SUCCESS: TESTS PASSED" ${TEST_LOG}) -gt 0 ]; then
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
