#!/bin/bash -e

# This script requires:
#  - Terraform
#  - Chef InSpec
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash terraform >/dev/null 2>&1; then
    echo "You need terraform installed to use this script"
    exit 1
fi

# Find inspec
if ! hash inspec >/dev/null 2>&1; then
    echo "You need inspec installed to use this script"
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

# Launch test server
terraform init
terraform apply -auto-approve -backup=-

# Save private key and IP address
terraform output private_key > temporary_key.pem
IP=$(terraform output IP)

# Run tests
inspec exec ../inspec -t ssh://${DEFAULT_USER}@${IP} -i temporary_key.pem || true

# Cleanup
terraform destroy -auto-approve -backup=-
rm temporary_key.pem
rm terraform.tfstate