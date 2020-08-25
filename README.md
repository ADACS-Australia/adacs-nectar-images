# ADACS NeCTAR images

This project is for build a set of ADACS images, suitable for the NeCTAR Research Cloud environment.

Each image is based on Nectar's official Ubuntu 18.04 (Bionic) image, but with a suite of additional software/applications pre-installed.

Main items in the repository are:
 * `packer.json` -- packer JSON config for building the image on the NeCTAR Research Cloud.
 * `ansible/master.yml` -- main ansible playbook for provisioning the image.
 * `scripts/clean.sh` -- shell script to 'clean' the image during provisioning.
 * `build.sh` -- shell script to drive the whole process.
 * `image_vars/` -- directory containing shell scripts for defining image specific environment variables.

## Requirements

You'll require the following tools installed and in your path
 * Packer
 * Ansible
 * OpenStack CLI

## Manually building an image

 1. Make sure all the required software (listed above) is installed
 2. Load your NeCTAR RC credentials into your environment
 3. `cd` to the directory containing this README.md file
 4. Run the build script for a given image, e.g.
```
IMG=image_vars/image_basic.sh ./build.sh
```

## Testing
To automatically launch an instance of the image and run a suite of tests via InSpec:
```
IMG=image_vars/image_basic.sh ./test.sh
```
This is achieved via Packer, and requires Chef InSpec to also be installed.
Note that the Packer build is forced to exit with an error in order to prevent it from creating an image, since here we only care about the test.

To do manual testing, navigate to `test/terraform`.
This directory contains scripts for launching and destroying a test server/instance.
Once launched, you can ssh into the machine to perform your own tests and check if things work.

## Notes:
This repository is based off https://github.com/NeCTAR-RC/packer-jupyternotebook.
