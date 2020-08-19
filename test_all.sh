#!/bin/bash -a

err=0
for IMG in ./image_vars/image_*; do
  source $IMG
  ./test.sh
  err=$((err+$?))
done

echo ''
echo '================================'
if ! [ "$err" == "0" ]; then
  echo "   FAILED TESTING ON ${err} IMAGES"
else
  echo "  PASSED TESTING ON ALL IMAGES"
fi
echo '================================'
