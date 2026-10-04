variable "application" {
  type = string
}
variable "environment" {
  type = string
}
variable "ami" {
  type        = string
  description = "us-east-1 = 'ami-0149b2da6ceec4bb0',us-east-1 = 'ami-06148e0e81e5187c8', ??=ami-02f3416038bdb17fb"
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
variable "template_vars" {
  type = map(any)
}
variable "s3_file_name" {
  type = string
}
variable "key_name" {
  type    = string
  default = null
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
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to the EC2 instance (merged with default Name/Environment/Application tags)"
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

variable "user_data" {
  type        = string
  description = "User data script that ASG uses"
}

variable "ansible_bucket_name" {
  type    = string
  default = null
}

variable "upload_location" {
  type    = string
  default = null
}

variable "sns" {
  type    = string
  default = null
}

variable "playbook" {
  type        = string
  description = "Ansible playbook name"
  default     = null
}

variable "ansible_playbook_name" {
  type        = string
  description = "Ansible playbook name"
  default     = null
}
variable "mails" {
  type = list(string)
}