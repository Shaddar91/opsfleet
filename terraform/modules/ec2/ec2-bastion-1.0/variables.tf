variable "application" {
  type = string
}
variable "environment" {
  type = string
}
variable "ami" {
  type        = string
  description = "AMI id for the instance"
}
variable "size" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "public_ip" {
  type    = bool
  default = null
}
variable "key_name" {
  type = string
}
variable "monitor" {
  type    = bool
  default = false
}
variable "source_dest_check" {
  type    = bool
  default = true
}
variable "tenancy" {
  type    = string
  default = "default"
}
variable "tags" {
  type    = map(any)
  default = null
}

variable "root_ebs" {
  type    = list(any)
  default = []
}

variable "disable_api_termination" {
  type    = bool
  default = false
}
variable "ebs_optimized" {
  type    = bool
  default = false
}
variable "private_ip" {
  type    = string
  default = null
}

variable "subnet" {
  type = string
}
variable "iam_role_name" {
  type    = string
  default = null
}

variable "iam_profile_name" {
  type    = string
  default = null
}

variable "sg_list" {
  type = string
}

variable "name" {
  type    = string
  default = null
}

variable "path" {
  type        = string
  description = "path to user data script and user_data script name"
}
variable "user_data_vars" {
  type        = map(any)
  description = "tempalte variables inside user data script"
  default     = {}
}

variable "ansible_bucket_name" {
  type    = string
  default = null
}