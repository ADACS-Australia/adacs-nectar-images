#!/bin/bash -e

echo "Building image..."
packer build packer.json

echo "Saving image locally..."
openstack --os-cloud=swin-dev image save --file packer-test_large.qcow2 packer-test

echo "Deleting image on openstack..."
openstack --os-cloud=swin-dev image delete packer-test

echo "Compressing image..."
qemu-img convert -c -o compat=0.10 -O qcow2 packer-test_large.qcow2 packer-test_small.qcow2
rm packer-test_large.qcow2

echo "Uploading compressed image to openstack..."
openstack --os-cloud=swin-dev image create --disk-format qcow2 --container-format bare --file packer-test_small.qcow2 packer-test