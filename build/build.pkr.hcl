source "openstack" "base_image" {
  communicator      = "ssh"
  flavor            = "m3.medium"
  image_name        = "${var.staging_name}"
  instance_name     = "${var.staging_name}"
  security_groups   = ["default", "SSH"]
  source_image_name = "${var.source_image}"
  ssh_username      = "${var.user}"
}

build {
  name    = "ADACS build"
  sources = ["source.openstack.base_image"]

  provisioner "ansible" {
    playbook_file   = "${var.playbook}"
    user            = "${var.user}"
    # Make sure ansible provisioner 'user' is the same as
    # openstack builder 'ssh_username'. This prevents the
    # '~local_user' directory being created on the remote.
  }

  # Reboot to flush /tmp
  provisioner "shell" {
    inline = ["sudo reboot"]
    expect_disconnect = true
  }

  provisioner "shell" {
    execute_command   = "{{ .Vars }} sudo --stdin --preserve-env bash '{{ .Path }}'"
    script            = "${var.scripts}/cleanup.sh"
  }
}
