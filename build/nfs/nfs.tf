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
  flavor_name     = "m3.xsmall"
  key_pair        = openstack_compute_keypair_v2.nfskey.name
  security_groups = ["default", "SSH"]
}

resource "openstack_dns_recordset_v2" "nfs_domain_name" {
  zone_id     = "d27379dc-17c4-4779-8779-e953cec5a5a8"
  name        = "nfs.swin-dev.cloud.edu.au."
  description = "Domain name for the NFS server"
  ttl         = 3600
  type        = "A"
  records     = [openstack_compute_instance_v2.nfsserver.access_ip_v4]
}

resource "openstack_compute_volume_attach_v2" "software" {
  instance_id = openstack_compute_instance_v2.nfsserver.id
  volume_id   = "faa29217-3d9b-4137-980a-5ad87307f550"
}

output "key" {
  sensitive = true
  value     = openstack_compute_keypair_v2.nfskey.private_key
}
