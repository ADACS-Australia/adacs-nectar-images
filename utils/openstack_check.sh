#!/bin/bash -e

# Get absolute path to directory containing the current file
DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
source ${DIR}/functions.sh

check_install nova
check_openstack_credentials

# Max wait time = 30s x 120 = 3600s = 60m = 1hr
WAIT_TIME=30
MAX_TRIES=120
NTRIES=0
CORES_NEEDED=2

while (( ${NTRIES} < ${MAX_TRIES} )); do
  NTRIES=$((${NTRIES}+1))

  # Split the 'nova limits' line containing cores/vcpu usage info
  IFS='| ' read -r -a CORES <<< "$(nova limits | grep Cores)"

  CORES_USED=CORES[2]
  CORES_MAX=CORES[3]
  CORES_AVAILABLE=$((${CORES_MAX} - ${CORES_USED}))

  if (( ${CORES_AVAILABLE} >= ${CORES_NEEDED} )); then
    echo "There are $CORES_AVAILABLE cores available."
    exit 0
  else
    >&2 echo "NOT ENOUGH CORES AVAILABLE. Retrying in ${WAIT_TIME}s"
    sleep ${WAIT_TIME}
  fi

done

>&2 echo "TIMED OUT"
exit 1
