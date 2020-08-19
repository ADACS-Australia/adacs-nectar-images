#!/bin/bash -a

for IMG in ./image_vars/image_*; do
  source $IMG
  ./test.sh
done
