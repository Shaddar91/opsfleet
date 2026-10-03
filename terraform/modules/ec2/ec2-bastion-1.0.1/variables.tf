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
  type        = string
  default     = null
  description = "Key pair name; null boots the instance without one"
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

variable "iam_instance_profile" {
  type        = string
  default     = null
  description = "Instance profile name, created by the caller"
}

variable "sg_list" {
  type = string
}

variable "user_data" {
  type        = string
  default     = null
  description = "Rendered user-data; a change replaces the instance"
}

variable "spot" {
  type        = bool
  default     = false
  description = "Run as a persistent Spot Instance at the current Spot price, capped at On-Demand; a change replaces the instance"
}
