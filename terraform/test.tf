# Set some variables
variable "test_image_name" {
  default = ""
}
variable "matlab_volume" {
  default = ""
}
variable "test_name" {
  default = ""
}

# Configure the OpenStack Provider
provider "openstack" { version = "~> 1.28" }

# Create temporary ssh key pair
resource "openstack_compute_keypair_v2" "test-keypair" {
  name = "adacs-image-testing-key"
}

# Launch VM with image to test
resource "openstack_compute_instance_v2" "test-server" {
  name            = var.test_name
  image_name      = var.test_image_name
  flavor_name     = "m3.small"
  key_pair        = openstack_compute_keypair_v2.test-keypair.name
  security_groups = ["default", "SSH"]

# Wait for ssh connection
  provisioner "remote-exec" {
    inline = ["echo '===> ssh is now available <==='"]

    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = openstack_compute_keypair_v2.test-keypair.private_key
    host        = openstack_compute_instance_v2.test-server.access_ip_v4
    }
  }
}

resource "openstack_compute_volume_attach_v2" "test-volume" {
  instance_id = openstack_compute_instance_v2.test-server.id
  volume_id   = var.matlab_volume
}

# Output varialbes
output "private_key" {
  sensitive = true
  value = openstack_compute_keypair_v2.test-keypair.private_key
}

output "IP" {
  value = openstack_compute_instance_v2.test-server.access_ip_v4
}
