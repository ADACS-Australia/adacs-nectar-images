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
check_usage $@
check_install openstack packer ansible terraform
check_openstack_credentials

set -u

# Set image variables
source $1

echo "--- Ensuring NFS software server is up..."
nslookup nfs.swin-dev.cloud.edu.au
echo "Initialising terraform..."
terraform -chdir=nfs init > /dev/null
echo "Getting key..."
NFS_KEY=$(terraform -chdir=nfs output -raw key)

echo
echo ">>>>> Building image: ${IMAGE_STAGENAME} <<<<<"


# Check if build name is not already taken/present
STATUS=$(openstack image show -c status -f value "${IMAGE_STAGENAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "WARNING: The image '${IMAGE_STAGENAME}' already exists!"
  echo "         Deleting it first..."
  openstack image delete ${IMAGE_STAGENAME}
fi

# Build and provision image
packer build -color=false -var-file="$1" .

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
    openstack image unset --property $PROPERTY "${IMAGE_STAGENAME}" || true
done
