# ADACS-Astro image

This project includes a script to build an image, suitable for the NeCTAR Research Cloud environment, with a suite of software/applications pre-installed.

The image is based on Nectar's official Ubuntu 18.04 (Bionic) image, but can be changed by editing the appropriate lines in the build script.

The repository contains:
 * `packer.json` -- packer JSON config for building the image on the NeCTAR Research Cloud.
 * `ansible/master.yml` -- ansible playbook for provisioning the image.
 * `scripts/clean.sh` -- shell script to 'clean' the image during provisioning.
 * `build.sh` -- shell script to drive the whole process.

Packages installed via `apt` are located in `ansible/vars/apt_packages.yml`.

Conda (MiniConda) is installed and activated by default.
Packages installed via `conda` are located in `ansible/vars/conda_packages.yml`.


## Requirements

You'll require the following tools installed and in your path
 * Packer
 * Ansible
 * OpenStack CLI
 * QEMU tools (for image shrinking process)

## Building the image

 1. Make sure all the required software (listed above) is installed
 2. Load your NeCTAR RC credentials into your environment
 3. `cd` to the directory containing this README.md file
 4. Run the build script
```
./build.sh
```

## Notes:

1. After the image is built and provisioned via packer, it is downloaded locally and 'shrunk' via `qemu-img`, before being re-uploaded to Nectar/OpenStack.
As a consequence, **many GB of local disk space is required** to run this script successfully.
You can choose the directory in which the large image files will be saved/shrunk with the variable `SAVE_DIR`

```
SAVE_DIR=/path/to/save/directory ./build.sh
```

2. This code is based off https://github.com/NeCTAR-RC/packer-jupyternotebook.

## Testing
To automatically launch an instance of the image and run a suite of tests via InSpec:
```
./test.sh
```
This is achieved via Packer, and requires Chef InSpec to also be installed.
Note that the Packer build is forced to exit with an error in order to prevent it from creating an image, since here we only care about the test.

To do manual testing, navigate to `test/terraform`.
This directory contains scripts for launching and destroying a test server/instance.
Once launched, you can ssh into the machine to perform your own tests and check if things work.
