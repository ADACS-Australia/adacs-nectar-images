#!/bin/bash -a
DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

err=0
for IMG in ${DIR}/../image_vars/image_*; do
  ${DIR}/test.sh --image ${IMG}
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
