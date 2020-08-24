#!/bin/bash -a

for IMG in ./image_vars/image_*; do
  ./build.sh
done
