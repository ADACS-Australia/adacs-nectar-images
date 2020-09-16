#!/bin/bash -eau

# This script requires:
#  - Terraform
#  - OpenStack credentials loaded in your environment

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/../../utils/functions.sh

# Checks
check_install terraform
check_openstack_credentials

# Set variables
IMG=$(get_image_vars_file "$@")
set -u
source ${DIR}/../../vars.sh

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
echo "      inspec exec \${INSPEC_PROFILE} -t ssh://${DEFAULT_USER}@${IP} -i ${TMP_KEY} --input-file \${CONDA_PACKAGES}"
echo
echo "To tear down the test instance run:"
echo
echo "      ./destroy_instance.sh"
echo
