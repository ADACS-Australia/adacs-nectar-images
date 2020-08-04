
for IMG in ./image_names/image_*; do

  set -a; source $IMG; set +a
  SAVE_DIR=${SAVE_DIR:-$(PWD)} ./build.sh

done
