# Source image to build upon
SOURCE_IMAGE_NAME='NeCTAR Ubuntu 18.04 LTS (Bionic) amd64'

# Define some image properties
DEFAULT_USER='ubuntu'
OS_DISTRO='ubuntu'
OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
PACKER_BUILD_NAME="ADACS_build_${IMAGE_TAGNAME}"
STAGED_NAME="ADACS_staged_${IMAGE_TAGNAME}"

# Name used for the image/server during testing
TEST_NAME='TEST_'${STAGED_NAME}
TEST_IMAGE=${STAGED_NAME}

# Volumes to attach during provisioning
SOFTWARE_VOLUME='software'
