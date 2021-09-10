#!/bin/bash -ea

# This script requires:
#  - OpenStack client
#  - Packer
#  - Ansible
#  - Terraform
#  - OpenStack credentials loaded in your environment
#  - Terraform credentials

NFS_DIR="./build/nfs/"
NFS_DOMAIN="nfs.swin-dev.cloud.edu.au"

# Get useful functions
source ./utils/functions.sh

# Checks
check_usage $@
check_install openstack packer ansible terraform
check_openstack_credentials

set -u

# Set image variables
source $1

echo "--- Ensuring NFS software server is up..."
nslookup ${NFS_DOMAIN}
echo "Initialising terraform..."
terraform -chdir=${NFS_DIR} init > /dev/null
echo "Getting key..."
NFS_KEY=$(terraform -chdir=${NFS_DIR} output -raw key)

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
packer build -color=false \
  -var "user=${DEFAULT_USER}" \
  -var "source_image=${SOURCE_IMAGE_NAME}" \
  -var "staging_name=${IMAGE_STAGENAME}" \
  -var "playbook=$(pwd)/build/ansible/${IMAGE_TAGNAME}.yml" \
  -var "scripts=$(pwd)/build/scripts" \
  ./build

echo "--- Unsetting image properties..."
# Try unsetting these properties, in case packer set them, but don't raise error
for PROPERTY in base_image_ref      \
                boot_roles          \
                image_location      \
                image_state         \
                image_type          \
                owner_project_name  \
                owner_user_name     \
                user_id
  do
    openstack image unset --property $PROPERTY "${IMAGE_STAGENAME}" || true
done

echo "COMPLETE"
