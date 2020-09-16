#!/bin/bash -eau

# This script requires:
#  - Terraform
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash terraform >/dev/null 2>&1; then
    echo "You need terraform installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
openstack quota show > /dev/null
if [ $? -ne 0 ]; then
    echo "--- Please load the OpenStack credentials! ---"
    echo "    (source your OpenStack RC file)"
    exit 1
fi

# Set variables
source ../vars.sh

# Export terraform variables
export TF_VAR_test_image_name=${TEST_IMAGE}
export TF_VAR_test_name=${TEST_NAME}

# Launch test instance
terraform init
terraform apply -auto-approve #-backup=-

TMP_KEY="temporary_key.pem"

# Save private key and IP address
terraform output private_key > ${TMP_KEY}
chmod 600 ${TMP_KEY}
IP=$(terraform output IP)

echo "=== Successfully launched test instance ==="
echo
echo "You can ssh into the machine with:"
echo
echo "      ssh -i ${TMP_KEY} ${DEFAULT_USER}@${IP}"
echo
echo "Template command for running the inspec test on this instance is:"
echo
echo "      inspec exec \${INSPEC_PROFILE} -t ssh://${DEFAULT_USER}@${IP} -i ${TMP_KEY} --input-file \${APT_PACKAGES} \${CONDA_PACKAGES}"
echo
echo "To tear down the test instance run:"
echo
echo "      ./destroy_instance.sh"
echo
