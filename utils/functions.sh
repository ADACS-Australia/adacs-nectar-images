function check_installed {
  for ITEM in "$@"; do
    if ! hash ${ITEM} >/dev/null 2>&1; then
        >&2 echo "You need ${ITEM} installed to use this script"
        exit 1
    fi
  done
  unset ITEM
}

function check_openstack_credentials {
  # Check if OpenStack credentials are loaded
  openstack quota show > /dev/null || local err=$?; true
  if [[ "$err" -ne 0 ]]; then
      >&2 echo "Please load your OpenStack credentials!"
      >&2 echo "(source your OpenStack RC file)"
      exit 1
  fi
}

function check_usage {
  if [ ! -f "$1" ]; then
    msg="Invalid positional argument: '$1' -- File does not exist."
    [ "$1" == "" ] && msg="Missing positional argument: <image options file>"
    >&2 cat <<EOF
${msg}
Usage:

  ./run.sh <path_to_image_options_file>

EOF
  exit 1
  fi
}

function check_resources {

  echo "--- Ensuring there are enough OpenStack resources available to proceed..."

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

}
