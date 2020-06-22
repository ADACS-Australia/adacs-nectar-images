#!/bin/bash

# This script requires:
#  - Terraform
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash terraform >/dev/null 2>&1; then
    echo "You need terraform installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

# Set variables
source ../../vars.sh

# Check if volumes are present and available
STATUS=$(openstack volume show -c status -f value ${MATLAB_VOLUME})
if [ "${STATUS}" != "available" ]; then
  echo The volume \'"${MATLAB_VOLUME}"\' is "$STATUS"
  openstack volume show "${MATLAB_VOLUME}"
  exit 1
fi

# Export terraform variables
export TF_VAR_test_image_name=${TEST_IMAGE}
export TF_VAR_matlab_volume=$(openstack volume show -c id -f value ${MATLAB_VOLUME})
export TF_VAR_test_name=${TEST_NAME}

# Launch test instance
terraform init
terraform apply -auto-approve #-backup=-

# Save private key and IP address
terraform output private_key > temporary_key.pem
chmod 600 temporary_key.pem
IP=$(terraform output IP)

echo "=== Successfully launched test instance ==="
echo
echo "You can run the Chef InSpec test with the command:"
echo
echo "      inspec exec ../inspec -t ssh://${DEFAULT_USER}@${IP} -i temporary_key.pem"
echo
echo "or simply ssh into the machine with:"
echo
echo "      ssh -i temporary_key.pem ${DEFAULT_USER}@${IP}"
echo
echo "To tear down the test instance run:"
echo
echo "      ./destroy_instance.sh"
echo
