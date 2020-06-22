set -a

# Source image to build upon
SOURCE_IMAGE_NAME='NeCTAR Ubuntu 18.04 LTS (Bionic) amd64'

# Name to upload image as
NEW_IMAGE_NAME='ADACS-Astro Ubuntu 18.04 LTS (Bionic) amd64 - unreleased'

# Define some image properties
DEFAULT_USER='ubuntu'
OS_DISTRO='ubuntu'
OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
BUILD_NAME='ADACS_astro_image_build'

# Name used for the image/server during testing
TEST_NAME='TEST_'${BUILD_NAME}

# Volumes to attach during provisioning
SOFTWARE_VOLUME='licensed_software'
MATLAB_VOLUME='matlab'

set +a
