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

function get_image_vars_file {
  if [ "$1" == "" ] || [ "$2" == "" ]; then
    >&2 echo "Please provide an input file with -i or --input"
    exit 1
  fi

  while [[ "$#" -gt 0 ]]; do
      case $1 in
          -i|--input|--image) local IMG="$2"; shift;;
          *)
          >&2 echo "Unknown parameter passed: $1"
          >&2 echo "Please provide an input file with -i or --input"
          exit 1 ;;
      esac
      shift
  done

  if [ ! -f "$IMG" ]; then
      >&2 echo "'$IMG' does not exist."
      exit 1
  fi

  echo "$IMG"
}
