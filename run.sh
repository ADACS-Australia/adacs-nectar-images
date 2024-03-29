#!/bin/bash -ea

# Get useful functions
source ./utils/functions.sh

# Checks
check_usage $@
check_installed openstack packer ansible terraform inspec
check_openstack_credentials

set -u

# Set image variables
source $1

NFS_DIR="./build/nfs/"
echo "--- Ensuring NFS software server is up..."
echo "Initialising terraform..."
terraform -chdir=${NFS_DIR} init > /dev/null
set +e
terraform -chdir=${NFS_DIR} output | grep -q "No outputs found"
if (( $? == 0 )); then echo "ERROR: nfs server may not be up."; exit 1; fi
set -e
echo "Getting key..."
NFS_KEY=$(terraform -chdir=${NFS_DIR} output -raw key)
echo "Getting IP..."
NFS_IP=$(terraform -chdir=${NFS_DIR} output -raw ip)
if [ "$(uname -s)" == "Darwin" ]; then netcat_opts="-w 5 -G 5"; else netcat_opts="-w 5"; fi
nc $netcat_opts -z $NFS_IP 22 || ( echo "ERROR: Could not connect to $NFS_IP via port 22" && exit 1 )


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
                murano_image_info   \
                user_id
  do
    openstack image unset --property $PROPERTY "${IMAGE_STAGENAME}" || true
done

echo "BUILD COMPLETE"


echo ">>>>> Testing image: ${IMAGE_STAGENAME} <<<<<"
echo

# Re-launch instance with packer and run inspec tests
packer build -color=false \
  -var "user=${DEFAULT_USER}" \
  -var "source_image=${IMAGE_STAGENAME}" \
  -var "instance_name=${TEST_SERVER_NAME}" \
  -var "inspec_profile=$(pwd)/test/inspec_profiles/${IMAGE_TAGNAME}" \
  -var "inspec_varsfile=$(pwd)/build/ansible/roles/conda/vars/main.yml" \
  ./test

echo "TESTING COMPLETE"


echo
echo ">>>>> Releasing image: ${IMAGE_RELEASENAME} <<<<<"
echo "       (from: ${IMAGE_STAGENAME} )"

# Delete old image if present before deploying
STATUS=$(openstack image show -c status -f value "${IMAGE_RELEASENAME}" 2> /dev/null || true)
if [ "${STATUS}" != "" ]; then
  echo "WARNING: The image '${IMAGE_RELEASENAME}' already exists!"
  echo "         Deleting it first..."
  openstack image delete "${IMAGE_RELEASENAME}"
fi

# Deploy the new/updated image
openstack image set --name "${IMAGE_RELEASENAME}" "${IMAGE_STAGENAME}"

# Set to a community image, if required
if [ "${COMMUNITY_IMAGE}" == "yes" ]; then
  openstack image set --community "${IMAGE_RELEASENAME}"
else
  openstack image set --shared "${IMAGE_RELEASENAME}"
fi

echo "COMPLETE"
