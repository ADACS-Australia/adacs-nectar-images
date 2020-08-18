#!/bin/bash -a

for IMG in ./image_names/image_*; do
  source $IMG
  SAVE_DIR=${SAVE_DIR:-$(PWD)} ./build.sh
done
