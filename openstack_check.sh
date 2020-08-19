#!/bin/bash -e

if ! hash nova >/dev/null 2>&1; then
    echo "You need nova installed to use this script"
    exit 1
fi

# Split the 'nova limits' line containing cores/vcpu usage info
IFS='| ' read -r -a CORES <<< "$(nova limits | grep Cores)"

CORES_USED=CORES[2]
CORES_MAX=CORES[3]

CORES_NEEDED=2
CORES_AVAILABLE=$((${CORES_MAX} - ${CORES_USED}))

if ((  ${CORES_AVAILABLE} >= ${CORES_NEEDED} )); then
  echo "There are $CORES_AVAILABLE cores available."
  exit 0
else
  echo "NOT ENOUGH CORES AVAILABLE"
  exit 1
fi
