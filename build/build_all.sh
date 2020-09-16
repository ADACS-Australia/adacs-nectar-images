#!/bin/bash
DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

for IMG in ${DIR}/../image_vars/image_*; do
  ${DIR}/build.sh --image "${IMG}"
done
