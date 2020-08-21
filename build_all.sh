#!/bin/bash -a

for IMG in ./image_vars/image_*; do
  IMG_VARS=$IMG ./build.sh
done
