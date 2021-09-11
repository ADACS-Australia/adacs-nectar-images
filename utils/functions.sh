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

function get_max_parallel {
  local openstack_limits="openstack.limits"
  local reqcores="2"
  openstack limits show --absolute -f value > $openstack_limits

  local maxvms=$(grep maxTotalInstances $openstack_limits| cut -d ' ' -f 2)
  local nvms=$(grep totalInstancesUsed $openstack_limits| cut -d ' ' -f 2)

  local maxcores=$(grep maxTotalCores $openstack_limits | cut -d ' ' -f 2)
  local ncores=$(grep totalCoresUsed $openstack_limits| cut -d ' ' -f 2)

  local nvms_avail=$(( $maxvms - $nvms ))
  local ncores_avail=$(( $maxcores - $ncores ))

  local nvms_from_cores=$(( $maxcores / $reqcores ))

  # Minimum of nvms_avail and nvms_from_cores
  local max_parallel=$(( $nvms_avail < $nvms_from_cores ? $nvms_avail : $nvms_from_cores ))

  if (( $max_parallel < 1 )); then
    echo "Not enough resources"
    exit 1
  else
    echo $max_parallel
    exit 0
  fi

}
