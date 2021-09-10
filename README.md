# ADACS NeCTAR images

This project is for build a set of ADACS images, suitable for the NeCTAR Research Cloud environment.

Each image is based on one of Nectar's official images (either Centos or Ubuntu), but with a suite of additional software/applications pre-installed.

Main items in the repository are:
 * `build/main.pkr.hcl` -- packer config template for building the image on the NeCTAR Research Cloud.
 * `build/ansible/master.yml` -- main ansible playbook for provisioning the image.
 * `build/scripts/clean.sh` -- shell script to 'clean' the image during provisioning.
 * `run.sh` -- shell script to drive the whole process.
 * `image_vars/` -- directory containing shell scripts for defining image specific environment variables.

## Requirements

You'll require the following tools installed and in your path
 * Packer
 * Ansible
 * OpenStack CLI
 * Inspec
 * Terraform

You'll also need to have a server up at `nfs.swin-dev.cloud.edu.au`, which hosts the software volume containing installation files for licensed software such as Mathematica, ABAQUS, etc. This can be launched via `Terraform` from the `build/nfs/` directory

```
cd build/nfs
terraform init
terraform apply
```

The image for this server instance can be built using the packer and the ansible playbook contained in that directory.

```
cd build/nfs
packer build packer_nfs.json
```

## GitHub actions
The image build --> test --> release lifecycle is managed through GitHub actions.
It will launch the NFS server, then build, test and release each image (if it passed the tests) in parallel.

## Manually building an image

 1. Make sure all the required software (listed above) is installed
 2. Load your NeCTAR RC credentials into your environment
 3. Run the main driver script for a given image, e.g.
```
./run.sh ./image_vars/image_basic.sh
```

## Testing
In the testing phase of the run script, packer will launch and instance of the staged image, then run a number of tests using Chef Inspec.

## Notes:
This repository was originally based off https://github.com/NeCTAR-RC/packer-jupyternotebook.
