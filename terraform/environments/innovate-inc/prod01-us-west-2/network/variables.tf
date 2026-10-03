variable "application" {
  description = "Name part of every network resource: <environment>-<application>-vpc, -igw, -ngw"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR; the subnet layout in main.tf needs a /16"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be an IPv4 /16: only a /16 leaves the bastion tier at /28, the smallest subnet AWS allows."
  }
}

variable "cluster_name" {
  description = "EKS cluster the private subnets' karpenter.sh/discovery tag names; must match the cluster stack"
  type        = string
}

variable "one_nat_gateway_per_az" {
  description = "One NAT gateway per AZ instead of one shared NAT: two more NAT gateways, no private egress outage when one AZ fails"
  type        = bool
}

variable "bastion_instance_type" {
  description = "Bastion instance type; the AMI architecture follows it (t4g is arm64)"
  type        = string
}

variable "bastion_spot" {
  description = "Run the bastion as a persistent Spot Instance: an interruption stops it and EC2 starts the same instance when capacity returns"
  type        = bool
}

variable "bastion_allowed_cidrs" {
  description = "CIDRs allowed to SSH to the bastion; [] leaves SSM Session Manager as the only way in. Export TF_VAR_bastion_allowed_cidrs from the env file outside the repo; terraform.tfvars would override it"
  type        = list(string)
}
