#!/bin/bash -e

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

terraform destroy -auto-approve #-backup=-
rm temporary_key.pem
# rm terraform.tfstate
