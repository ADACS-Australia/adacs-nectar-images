# Required input variables

variable "user" {
  description = "SSH user to conect to the instance with i.e. the default user in the source image"
  type = string
}

variable "source_image" {
  description = "Full name of the source image for packer to run inspec tests on."
  type = string
}

variable "instance_name" {
  description = "The name of the test server."
  type = string
}

variable "inspec_profile" {
  description = "Full path to the inspec profile to use for testing."
  type = string
}

variable "inspec_varsfile" {
  description = "Full path to the file containing variables to be used for inspec."
  type = string
}
