variable "application" {
  description = "Name part of the node security group, the launch templates and the node names, <environment>-<application>-<group>"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, its karpenter.sh/discovery value and the prefix of the three IAM role names; must equal the network stack's cluster_name, which tags the private subnets"
  type        = string
  default     = "prod01-us-eks"

  validation {
    condition     = can(regex("^[0-9A-Za-z][0-9A-Za-z_-]{0,43}$", var.cluster_name))
    error_message = "cluster_name must be 1-44 letters, digits, hyphens or underscores, starting with a letter or digit: the role name <cluster_name>-karpenter-node-role must fit IAM's 64 characters."
  }

  validation {
    condition     = var.cluster_name == local.network_cluster_name
    error_message = "cluster_name must equal the network stack's cluster_name, ${local.network_cluster_name}, the private subnets' karpenter.sh/discovery value; change both and roll the network first."
  }
}

variable "cluster_version" {
  description = "Kubernetes minor version of the control plane; the node groups follow it"
  type        = string
  default     = "1.36"
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint; export TF_VAR_public_access_cidrs from the env file outside the repo"
  type        = list(string)

  validation {
    condition     = length(var.public_access_cidrs) > 0 && alltrue([for cidr in var.public_access_cidrs : can(cidrhost(cidr, 0))])
    error_message = "public_access_cidrs must list at least one CIDR: the provider drops an empty list and EKS then opens the public endpoint to 0.0.0.0/0."
  }
}

variable "admin_principal_arns" {
  description = "IAM role or user ARNs given AmazonEKSClusterAdminPolicy through access entries; must include the principal that runs tfctl.sh, or the components tier gets 401/403. Export TF_VAR_admin_principal_arns from the env file outside the repo"
  type        = set(string)

  validation {
    condition     = length(var.admin_principal_arns) > 0 && alltrue([for arn in var.admin_principal_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(role|user)/.+", arn))])
    error_message = "admin_principal_arns must list at least one IAM role or user ARN, arn:aws:iam::<account>:role/<name>; for an assumed-role session give the role ARN, not the sts assumed-role ARN."
  }
}

variable "addon_versions" {
  description = "Managed add-on version pins keyed by add-on name; an unpinned add-on takes the EKS default for cluster_version. Pin from the addon_versions output after the first apply"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for name in keys(var.addon_versions) : contains(keys(local.addons), name)])
    error_message = "addon_versions keys must be vpc-cni, kube-proxy, eks-pod-identity-agent or coredns."
  }
}
