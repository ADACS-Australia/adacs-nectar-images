source "openstack" "image_build" {
  communicator      = "ssh"
  flavor            = "m3.small"
  image_name        = "${var.IMAGE_BUILDNAME}"
  instance_name     = "${var.IMAGE_BUILDNAME}"
  security_groups   = ["default", "SSH"]
  source_image_name = "${var.SOURCE_IMAGE_NAME}"
  ssh_username      = "${var.DEFAULT_USER}"
}

build {
  name = "adacs-image"
  sources = ["source.openstack.image_build"]

  provisioner "ansible" {
    playbook_file   = "ansible/${var.IMAGE_TAGNAME}.yml"
    user            = "${var.DEFAULT_USER}"
    # Make sure ansible provisioner 'user' is the same as
    # openstack builder 'ssh_username'. This prevents the
    # '~local_user' directory being created on the remote.
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo --stdin --preserve-env bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }

}
