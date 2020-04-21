#!/bin/bash -e

packer build packer.json

openstack --os-cloud=swin-dev image save --file packer-test_large.qcow2 packer-test
openstack --os-cloud=swin-dev image delete packer-test

qemu-img convert -c -o compat=0.10 -O qcow2 packer-test_large.qcow2 packer-test_small.qcow2
rm packer-test_large.qcow2

openstack --os-cloud=swin-dev image create --file packer-test_small.qcow2 packer-test