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

variable "create_nat_gateway" {
  type        = bool
  default     = true
  description = "Create the NAT gateway and the private route table's default route through it"
}

variable "flow_logs_iam_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for VPC Flow Logs. If null, creates a new role in this module"
}

variable "flow_logs_traffic_type" {
  type        = string
  default     = "REJECT"
  description = "Traffic type to capture: ACCEPT, REJECT, or ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be ACCEPT, REJECT, or ALL"
  }
}

variable "flow_logs_custom_format" {
  type        = bool
  default     = false
  description = "Enable custom log format with enhanced fields (vpc-id, subnet-id, instance-id, etc.)"
}

variable "flow_logs_retention_days" {
  type        = number
  default     = 60
  description = "CloudWatch log group retention in days"
}

variable "flow_logs_kms_encryption" {
  type        = bool
  default     = false
  description = "Enable KMS encryption for flow logs CloudWatch log group"
}

variable "flow_logs_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for flow logs encryption. If null and encryption enabled, creates a new key"
}

variable "enable_s3_endpoint" {
  type        = bool
  default     = false
  description = "Create S3 Gateway Endpoint. Routes S3 traffic through AWS backbone instead of NAT. Free, saves NAT data costs."
}

variable "enable_ec2_endpoint" {
  type        = bool
  default     = false
  description = "Create an EC2 interface endpoint in the private subnets"
}

variable "ec2_endpoint_allowed_sg_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs allowed to reach the EC2 interface endpoint on 443"
}

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