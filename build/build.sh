#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - Packer
#  - Ansible
#  - Terraform
#  - OpenStack credentials loaded in your environment
#  - Terraform credentials

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/../utils/functions.sh

# Checks
check_install openstack packer ansible terraform
check_openstack_credentials

# Set variables
IMG=$(get_image_vars_file "$@")
set -u
source ${DIR}/../vars.sh
PACKER_TEMPLATE=${DIR}/packer.json

echo "--- Ensuring NFS software server is up..."
nslookup nfs.swin-dev.cloud.edu.au
cd ${DIR}/nfs
echo "Initialising terraform..."
terraform init > /dev/null
echo "Getting key..."
NFS_KEY=$(terraform output key)
echo "Changing back to build directory..."
cd -

echo
echo ">>>>> Building image: ${IMAGE_BUILDNAME} <<<<<"

# Check if build name is not already taken/present
STATUS=$(openstack image show -c status -f value "${IMAGE_BUILDNAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "WARNING: The image '${IMAGE_BUILDNAME}' already exists!"
  echo "         Deleting it first..."
  openstack image delete ${IMAGE_BUILDNAME}
fi

# Build and provision image
packer build -color=false ${PACKER_TEMPLATE}

# Try unsetting these properties, in case packer set them, but don't raise error
for PROPERTY in base_image_ref      \
                boot_roles          \
                image_location      \
                image_state         \
                image_type          \
                murano_image_info   \
                os_hash_algo        \
                os_hash_value       \
                os_hidden           \
                owner_project_name  \
                owner_user_name     \
                stores              \
                user_id             \
                owner_specified.openstack.sha256 \
                owner_specified.openstack.object \
                owner_specified.openstack.md5
  do
    openstack image unset --property $PROPERTY "${IMAGE_BUILDNAME}" || true
done
