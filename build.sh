#!/bin/bash -e

# This script requires:
#  - Packer
#  - jq (JSON CLI tool)
#  - QEMU tools
#  - OpenStack credentials loaded in your environment

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Find jq
if ! hash jq >/dev/null 2>&1; then
    echo "You need jq installed to use this script"
    exit 1
fi

if [ -z "${OS_CLOUD}" ]; then
    echo "Please load the OpenStack credentials"
    echo "export OS_CLOUD = <my_cloud> "
    echo "where <my_cloud> is defined in a clouds.yaml file"
    exit 1
fi

FILE=packer.json
IMAGE_NAME=$(jq -r '.builders[0].image_name' ${FILE})

set -x # Print commands as they are run

# Build and provision image
packer build ${FILE}

# Save image locally
openstack image save --file ${IMAGE_NAME}_large.qcow2 ${IMAGE_NAME}

# Delete image on openstack
openstack image delete ${IMAGE_NAME}

# Compress image
qemu-img convert -c -o compat=0.10 -O qcow2 ${IMAGE_NAME}_large.qcow2 ${IMAGE_NAME}_small.qcow2
rm ${IMAGE_NAME}_large.qcow2

# Upload smaller image to openstack and delete local file
openstack image create --disk-format qcow2 --container-format bare --file ${IMAGE_NAME}_small.qcow2 ${IMAGE_NAME}
rm ${IMAGE_NAME}_small.qcow2

# Set and unset some image properties
openstack image set --property default_user=ubuntu ${IMAGE_NAME} || true
sleep 10
openstack image set --property nectar_name=${IMAGE_NAME} ${IMAGE_NAME} || true
sleep 10
openstack image set --property os_distro=ubuntu ${IMAGE_NAME} || true
sleep 10
openstack image set --property os_version=18.04 ${IMAGE_NAME} || true
sleep 10

openstack image unset --property owner_specified.openstack.sha256 ${IMAGE_NAME} || true
openstack image unset --property owner_specified.openstack.object ${IMAGE_NAME} || true
openstack image unset --property owner_specified.openstack.md5 ${IMAGE_NAME} || true