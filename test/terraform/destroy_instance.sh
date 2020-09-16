#!/bin/bash -e

# This script requires:
#  - Terraform
#  - OpenStack credentials loaded in your environment

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/../../utils/functions.sh

# Checks
check_install terraform
check_openstack_credentials

terraform destroy -auto-approve
rm temporary_key.pem
