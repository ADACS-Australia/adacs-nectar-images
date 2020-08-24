# Source image to build upon
SOURCE_IMAGE_NAME='NeCTAR Ubuntu 18.04 LTS (Bionic) amd64'

# Define some image properties
DEFAULT_USER='ubuntu'
OS_DISTRO='ubuntu'
OS_VERSION='18.04'

# Name to use for the temporary image during provisioning
IMAGE_BUILDNAME="ADACS_build_${IMAGE_TAGNAME}"

# Name used for the image/server during testing
TEST_NAME='TEST_'${IMAGE_BUILDNAME}
TEST_IMAGE=${IMAGE_BUILDNAME}

# Volumes to attach during provisioning
SOFTWARE_VOLUME='software'
