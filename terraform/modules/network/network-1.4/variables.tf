data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable "application" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = null
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "bastion_ami" {
  type = string
}

variable "allowed_ips" {
  type    = list(any)
  default = []
}
variable "bastion_subnets" {
  type    = any
  default = []
}

variable "private_subnets" {
  type    = any
  default = []
}

variable "public_subnets" {
  type    = any
  default = []
}

variable "internal_subnets" {
  type    = list(any)
  default = []
}

variable "lambda_subnets" {
  type    = list(any)
  default = []
}

variable "vpc_cidr" {
  type = string
}

variable "flow_logs_iam_role_name" {
  type        = string
  description = "Name of an existing IAM role in this account that the VPC flow log uses"
}

variable "ssh_key" {
  type        = string
  description = "key for bastion"
}

variable "ngw_public_subnet_index" {
  type        = number
  default     = 0
  description = "The index of the public subnet to use for that NAT Gateway"
}

variable "rules_cidr" {
  type = list(any)
}
variable "ansible_bucket_name" {
  type = string
}
variable "bastion_playbook_name" {
  type        = string
  description = "Playbook name passed to the bastion user data template as playbook_name"
}

variable "create_internal_hosted_zone" {
  type    = bool
  default = false
}
variable "hosted_zone_name" {
  type        = string
  description = "The name of the hosted zone"
  default     = null
}
variable "r53_record_type" {
  type    = string
  default = null
}

variable "r53_ttl" {
  type        = string
  description = ""
  default     = null
}

variable "internal_zone_name" {
  type        = string
  description = "The name of the internal hosted zone"
  default     = null
}

variable "zone_id" {
  type        = string
  description = "The ID of the hosted zone"
  default     = null
}

variable "region" {
  type = string
}

//=============================================================================
// Transit Gateway Variables
//=============================================================================

variable "enable_tgw_attachment" {
  type        = bool
  default     = false
  description = "Enable Transit Gateway attachment (creates ENIs, no traffic impact)"
}

variable "enable_tgw_routing" {
  type        = bool
  default     = false
  description = "Enable routing via Transit Gateway (changes route table, breaks traffic until TGW is ready)"
}

variable "transit_gateway_id" {
  type        = string
  default     = null
  description = "Transit Gateway ID to attach to (required if enable_tgw_attachment or enable_tgw_routing is true)"
}

variable "tgw_attachment_subnet_ids" {
  type        = list(string)
  default     = null
  description = "Subnet IDs for TGW attachment (typically private subnets). If null, uses all private subnets."
}