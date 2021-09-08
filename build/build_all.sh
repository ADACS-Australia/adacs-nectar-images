#!/bin/bash

# Note: this build all the images in series,
# so it will take a very long time.

for input_file in ../image_vars/image_*.sh.hcl; do
  ./build.sh "${input_file}"
done
