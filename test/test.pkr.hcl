source "openstack" "staged_image" {
  communicator      = "ssh"
  flavor            = "m3.small"
  image_name        = "${var.instance_name}"
  instance_name     = "${var.instance_name}"
  security_groups   = ["default", "SSH"]
  source_image_name = "${var.source_image}"
  ssh_username      = "${var.user}"
  skip_create_image = true
}

build {
  name = "ADACS test"
  sources = ["source.openstack.staged_image"]

  provisioner "inspec" {
    profile         = "${var.inspec_profile}"
    user            = "${var.user}"
    extra_arguments = [
      "--input-file=${var.inspec_varsfile}",
      "--no-create-lockfile",
      "--chef-license=accept-silent",
      "--shell",
      "--shell-command=/bin/bash",
      "--shell-options='-i'"
      ]
  }

}
