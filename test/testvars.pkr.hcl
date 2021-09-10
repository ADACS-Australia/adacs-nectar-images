# Required input variables

variable "inspec_controls" {
  type    = string
  default = "${env("INSPEC_CONTROLS")}"
}

variable "inspec_profile" {
  type    = string
  default = ""
}

variable "inspec_varsfile" {
  type    = string
  default = "${env("INSPEC_VARSFILE")}"
}

variable "ssh_user" {
  type    = string
  default = "${env("DEFAULT_USER")}"
}

variable "test_image" {
  type    = string
  default = "${env("IMAGE_STAGENAME")}"
}

variable "test_server_name" {
  type    = string
  default = "${env("TEST_SERVER_NAME")}"
}
