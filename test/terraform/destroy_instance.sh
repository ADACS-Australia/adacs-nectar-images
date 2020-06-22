# Find packer
if ! hash terraform >/dev/null 2>&1; then
    echo "You need terraform installed to use this script"
    exit 1
fi

# Check if OpenStack credentials are loaded
if [ -z "${OS_USERNAME}" ]; then
    echo -e "Please load the OpenStack credentials! \n"
    echo    "(source your OpenStack RC file)"
    exit 1
fi

terraform destroy -auto-approve #-backup=-
rm temporary_key.pem
# rm terraform.tfstate
