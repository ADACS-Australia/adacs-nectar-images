# Required input variables

variable "user" {
  description = "SSH user to conect to the instance with i.e. the default user in the source image"
  type = string
}

variable "source_image" {
  description = "Full name of the source image for packer to build on."
  type = string
}

variable "staging_name" {
  description = "The name of the artefact being uploaded to nectar/openstack after the build."
  type = string
}

variable "playbook" {
  description = "Full path to the ansible playbook to use during provisioning."
  type = string
}

variable "scripts" {
  description = "Full path to the directory containing any provisioning shell scripts."
  type = string
}
