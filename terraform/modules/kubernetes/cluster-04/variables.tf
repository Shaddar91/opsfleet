variable "environment" {
 type = string  
}

variable "application" {
 type = string  
}
variable "cluster_verison" {
  type = string
  default = "1.33"
}

variable "vpc_id" {
  type = string
}

variable "endpoint_private_access" {
  type = bool
  description = " (Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false."
  default = true
}
variable "endpoint_public_access" {
  type = bool
  description = "Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true"
  default = false
}
variable "node_groups" {
  description = "List of node group maps, each describing a single node group configuration."
  type = list(object({
    name                 = string
    subnets              = list(string)
    capacity_type        = string
    instance_types       = list(string)
    scaling              = object({
      desired = number
      min     = number
      max     = number
    })
    ami_type             = optional(string)
    node_version         = optional(string)
    extra_security_group_ids = optional(list(string), [])
    image_id             = optional(string)
    ebs                  = optional(object({
      size       = number
      iops       = number
      throughput = number
      type       = string
    }))
    labels               = optional(map(string))
    taints               = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags                 = optional(map(string))
  }))
}



variable "cluster_subnet_ids" {
 type = list(string)
}
variable "extra_security_group_ids" {
  type = list(string)
  default = []
}

variable "rules_cidr" {
  description = "List of CIDR-based ingress rules"
  type = list(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
    cidrs     = list(string)
  }))
  default = [
    { type = "ingress", from_port = 0,  to_port = 0,  protocol = "-1", cidrs = ["0.0.0.0/0"] },
    { type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidrs = ["0.0.0.0/0"] },
    { type = "egress",  from_port = 0,  to_port = 0,  protocol = "-1", cidrs = ["0.0.0.0/0"] }
  ]
}


variable "rules_sg" {
  description = "list of security-group-based ingress rules"
  type = list(object({
    type      = string
    from_port = number
    to_port   = number
    protocol  = string
    source_sg = string
  }))
}
variable "node_policy_file_location" {
  description = "Path to the node policy JSON file for the EC2 role."
  type        = string
  # Note: Using an interpolation (like ${path.module}) in a default is not allowed because defaults must be constant.
  # Instead, either pass this in from your root module or set it via a local.
}

variable "node_policy_template_vars" {
  description = "Map of values to template into the node policy JSON file."
  type        = map(string)
  default     = {}  // You can override this in the module call if needed.
}
variable "extra_cluster_policy_list" {
  type = list(string)
  default = []
}

variable "default_cluster_role_policy_list" {
  type = list(string)
  description = "default cluster policy list"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}
variable "default_ec2_role_policy_list" {
  type = list(string)
  description = "default policy list"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

variable "extra_ec2_policy_list" {
  description = "Additional policies for EC2 node role"
  type        = list(string)
  default     = []
}


variable "update_default_version" {
 type = bool
 default = true
}
variable "device_name" {
 type = string
 default="/dev/xvda"
}
variable "ebs" {
  type = object({
    size       = number
    iops       = number
    throughput = number
    type       = string
  })
  description = "EBS volume configurations"
  default = {
    size       = 50
    iops       = 100
    throughput = 125
    type       = "gp3"
  }
}


variable "image_id" {
 type = string
 default=null
}

variable "capacity_reservation_preference" {
 type = string
 description = "open or none"
 default = "none"
}

variable "http_endpoint" {
 type = string
 default = "enabled"
}

variable "http_tokens" {
 type = string 
 default = "required" 
}

variable "http_put_response_hop_limit" {
 type = string
 default = 2
}

variable "http_protocol_ipv6" {
 type = string
 default = null
}

variable "instance_metadata_tags" {
 type = string
 default = null
}

variable "user_data" {
  description = "Path to the user_data script file"
  type        = string
}

variable "user_data_vars" {
  description = "Map of variables for templating the user_data script (if needed). Pass an empty map if no templating is required."
  type        = map(any)
  default     = {}
}