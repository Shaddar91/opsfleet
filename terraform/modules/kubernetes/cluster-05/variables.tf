variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "Cluster name; null gives <environment>-<application>-eks. Also the karpenter.sh/discovery value"
}

variable "cluster_version" {
  type     = string
  default  = "1.36"
  nullable = false
  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.cluster_version))
    error_message = "cluster_version is a Kubernetes minor version such as \"1.36\"."
  }
}

variable "cluster_role_arn" {
  type        = string
  description = "Cluster IAM role ARN, created by the caller through the iam/role module"
  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/", var.cluster_role_arn))
    error_message = "cluster_role_arn must be an IAM role ARN."
  }
}

variable "node_role_arn" {
  type        = string
  description = "Managed node group IAM role ARN, created by the caller through the iam/role module"
  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/", var.node_role_arn))
    error_message = "node_role_arn must be an IAM role ARN."
  }
}

variable "authentication_mode" {
  type     = string
  default  = "API"
  nullable = false
  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be API or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  type        = bool
  default     = false
  nullable    = false
  description = "Create-time only; a change replaces the cluster. With false, access_entries must hold the principal that runs Terraform"
}

variable "bootstrap_self_managed_addons" {
  type        = bool
  default     = true
  nullable    = false
  description = "Create-time only; a change replaces the cluster"
}

variable "access_entries" {
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    kubernetes_groups = optional(list(string))
    user_name         = optional(string)
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = optional(object({
        type       = string
        namespaces = optional(list(string))
      }), { type = "cluster" })
    })), {})
  }))
  default  = {}
  nullable = false
  validation {
    condition     = alltrue([for entry in values(var.access_entries) : contains(["STANDARD", "EC2_LINUX"], entry.type)])
    error_message = "access_entries type must be STANDARD or EC2_LINUX."
  }
  validation {
    condition = alltrue([for entry in values(var.access_entries) : entry.type == "STANDARD" ? true : (
      try(length(entry.kubernetes_groups), 0) == 0 && entry.user_name == null && length(entry.policy_associations) == 0
    )])
    error_message = "An EC2_LINUX access entry takes no kubernetes_groups, user_name or policy_associations."
  }
  validation {
    condition     = length(distinct([for entry in values(var.access_entries) : entry.principal_arn])) == length(var.access_entries)
    error_message = "A principal_arn may appear in one access entry only."
  }
  validation {
    condition = alltrue(flatten([for entry in values(var.access_entries) : [for policy in values(entry.policy_associations) : (
      policy.access_scope.type == "cluster" ? try(length(policy.access_scope.namespaces), 0) == 0 : policy.access_scope.type == "namespace" && try(length(policy.access_scope.namespaces), 0) > 0
    )]]))
    error_message = "access_scope type is cluster (no namespaces) or namespace (with namespaces)."
  }
}

variable "addons" {
  type = map(object({
    version                     = optional(string)
    most_recent                 = optional(bool, false)
    before_compute              = optional(bool, false)
    configuration_values        = optional(string)
    service_account_role_arn    = optional(string)
    pod_identity                = optional(object({ role_arn = string, service_account = string }))
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
  }))
  default = {
    vpc-cni                = { before_compute = true }
    kube-proxy             = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    coredns                = {}
  }
  nullable    = false
  description = "EKS managed add-ons keyed by add-on name; version null resolves the EKS default for cluster_version"
  validation {
    condition = alltrue([for addon in values(var.addons) : (
      contains(["NONE", "OVERWRITE"], addon.resolve_conflicts_on_create) && contains(["NONE", "OVERWRITE", "PRESERVE"], addon.resolve_conflicts_on_update)
    )])
    error_message = "resolve_conflicts_on_create is NONE or OVERWRITE; resolve_conflicts_on_update is NONE, OVERWRITE or PRESERVE."
  }
}

variable "karpenter_discovery_tag" {
  type        = bool
  default     = true
  nullable    = false
  description = "Tag the EKS cluster security group karpenter.sh/discovery = <cluster name>"
}

variable "cluster_security_group_tags" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "upgrade_policy_support_type" {
  type        = string
  default     = null
  description = "STANDARD or EXTENDED; null keeps the EKS default"
  validation {
    condition     = var.upgrade_policy_support_type == null ? true : contains(["STANDARD", "EXTENDED"], var.upgrade_policy_support_type)
    error_message = "upgrade_policy_support_type must be STANDARD or EXTENDED."
  }
}

variable "vpc_id" {
  type = string
}

variable "endpoint_private_access" {
  type        = bool
  description = " (Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false."
  default     = true
}
variable "endpoint_public_access" {
  type        = bool
  description = "Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true"
  default     = false
}
variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  nullable    = false
  description = "CIDRs allowed to reach the public API endpoint when endpoint_public_access is true"
}

variable "node_groups" {
  description = "List of node group maps, each describing a single node group configuration."
  type = list(object({
    name           = string
    subnets        = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    instance_types = list(string)
    scaling = object({
      desired = number
      min     = number
      max     = number
    })
    ami_type                 = optional(string)
    node_version             = optional(string)
    release_version          = optional(string)
    image_id                 = optional(string)
    extra_security_group_ids = optional(list(string))
    ebs = optional(object({
      size        = number
      iops        = number
      throughput  = number
      type        = string
      device_name = optional(string)
    }))
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
    tags = optional(map(string), {})
  }))
  validation {
    condition     = length(distinct([for ng in var.node_groups : ng.name])) == length(var.node_groups)
    error_message = "node_groups names must be unique."
  }
  validation {
    condition = alltrue([for ng in var.node_groups : ng.ami_type == null ? true : contains(
      ["AL2023_x86_64_STANDARD", "AL2023_ARM_64_STANDARD", "AL2023_x86_64_NVIDIA", "AL2023_ARM_64_NVIDIA", "AL2023_x86_64_NEURON"], ng.ami_type
    )])
    error_message = "ami_type must be AL2023_x86_64_STANDARD, AL2023_ARM_64_STANDARD, AL2023_x86_64_NVIDIA, AL2023_ARM_64_NVIDIA or AL2023_x86_64_NEURON."
  }
  validation {
    condition     = alltrue([for ng in var.node_groups : contains(["ON_DEMAND", "SPOT"], ng.capacity_type)])
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
  validation {
    condition     = alltrue(flatten([for ng in var.node_groups : [for t in ng.taints : contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], t.effect)]]))
    error_message = "Taint effect must be NO_SCHEDULE, NO_EXECUTE or PREFER_NO_SCHEDULE."
  }
  validation {
    condition = alltrue([for ng in var.node_groups : ng.update_config == null ? true : (
      (ng.update_config.max_unavailable == null) != (ng.update_config.max_unavailable_percentage == null)
    )])
    error_message = "update_config sets exactly one of max_unavailable and max_unavailable_percentage."
  }
  validation {
    condition     = alltrue([for ng in var.node_groups : ng.image_id == null ? true : ng.ami_type == null && ng.node_version == null && ng.release_version == null])
    error_message = "A node group with image_id takes no ami_type, node_version or release_version."
  }
  validation {
    condition     = alltrue([for ng in var.node_groups : ng.scaling.min <= ng.scaling.desired && ng.scaling.desired <= ng.scaling.max])
    error_message = "Node group scaling must satisfy min <= desired <= max."
  }
}



variable "cluster_subnet_ids" {
  type = list(string)
}
variable "extra_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security groups added to every node group that sets no extra_security_group_ids of its own"
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
    { type = "ingress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] },
    { type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidrs = ["0.0.0.0/0"] },
    { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] }
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
  default = []
}


variable "node_group_timeouts" {
  type = object({
    create = optional(string, "30m")
    update = optional(string, "2h")
    delete = optional(string, "30m")
  })
  default     = {}
  nullable    = false
  description = "Create, update and delete timeouts for every EKS node group"
}

variable "update_default_version" {
  type    = bool
  default = true
}
variable "device_name" {
  type    = string
  default = "/dev/xvda"
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

variable "capacity_reservation_preference" {
  type        = string
  description = "open or none"
  default     = "none"
}

variable "http_endpoint" {
  type    = string
  default = "enabled"
}

variable "http_tokens" {
  type    = string
  default = "required"
}

variable "http_put_response_hop_limit" {
  type    = string
  default = 2
}

variable "http_protocol_ipv6" {
  type    = string
  default = null
}

variable "instance_metadata_tags" {
  type    = string
  default = null
}

variable "user_data" {
  description = "Path to a MIME multipart user-data template; null uses the module's files/user_data.tpl"
  type        = string
  default     = null
}

variable "user_data_vars" {
  description = "Map of variables for templating the user_data script (if needed). Pass an empty map if no templating is required."
  type        = map(any)
  default     = {}
}
