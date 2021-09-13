terraform {
  backend "remote" {
    organization = "adacs"

    workspaces {
      name = "software-nfs"
    }
  }

  required_providers {
    openstack = {
      source = "terraform-providers/openstack"
    }
  }
  required_version = ">= 0.13"
}

provider "openstack" {}

resource "openstack_compute_keypair_v2" "nfskey" {
  name = "nfs-key"
}

resource "openstack_compute_instance_v2" "nfsserver" {
  name            = "NFS-server"
  image_name      = "NFS-server"
  flavor_name     = "m3.medium"
  key_pair        = openstack_compute_keypair_v2.nfskey.name
  security_groups = ["default", "SSH"]
}

resource "openstack_compute_volume_attach_v2" "software" {
  instance_id = openstack_compute_instance_v2.nfsserver.id
  volume_id   = "faa29217-3d9b-4137-980a-5ad87307f550"
}

output "key" {
  sensitive = true
  value     = openstack_compute_keypair_v2.nfskey.private_key
}

output "ip" {
  sensitive = true
  value     = openstack_compute_instance_v2.nfsserver.access_ip_v4
}
