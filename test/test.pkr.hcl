source "openstack" "staged_image" {
  communicator      = "ssh"
  flavor            = "m3.small"
  image_name        = "${var.test_name}"
  instance_name     = "${var.test_name}"
  security_groups   = ["default", "SSH"]
  source_image_name = "${var.test_image}"
  ssh_username      = "${var.ssh_user}"
}

build {
  name = "ADACS test"
  sources = ["source.openstack.staged_image"]
  skip_create_image = true

  provisioner "inspec" {
    extra_arguments = ["--input-file=${var.inspec_varsfile}"]
    inspec_env_vars = ["CHEF_LICENSE=accept"]
    profile         = "${var.inspec_profile}"
    user            = "${var.ssh_user}"
  }

}
