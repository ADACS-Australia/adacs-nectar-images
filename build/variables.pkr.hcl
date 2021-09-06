# Required input variables

variable "IMAGE_TAGNAME" {
  description = "The 'tag' name for the image being built. This should match the playbook filename (without the .yml)"
  type = string
}

variable "IMAGE_BUILDNAME" {
  description = "The name of the artefact being uploaded to nectar/openstack after the build."
  type = string
}

variable "SOURCE_IMAGE_NAME" {
  description = "Full name of the source image for packer to build on."
  type = string
}

variable "DEFAULT_USER" {
  description = "SSH user to conect to the instance with i.e. the default user in the source image"
  type = string
}
