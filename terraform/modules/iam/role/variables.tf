variable "aws_service" {
  type    = string
  default = null
}
variable "policy_list" {
  type    = list(any)
  default = []
}
variable "environment" {
  type    = string
  default = null
}
variable "application" {
  type    = string
  default = null
}
variable "custom_policy" {
  type    = bool
  default = false
}
variable "policy_file" {
  default = null
}
variable "instance_profile" {
  type    = bool
  default = false
}

variable "assume_role_policy" {
  default = null
}

variable "name" {
  type    = string
  default = null
}

variable "max_session_duration" {
  type = string
  default = null
}