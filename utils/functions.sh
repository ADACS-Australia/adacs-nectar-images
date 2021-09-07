function check_install {
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

  ./build.sh <path_to_image_options_file>

EOF
  exit 1
  fi
}
