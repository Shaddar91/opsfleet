variable "application" {
  description = "Name part of the node security group, the launch templates and the node names, <environment>-<application>-<group>"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, its karpenter.sh/discovery value and the prefix of the three IAM role names; must equal the network stack's cluster_name, which tags the private subnets"
  type        = string

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
}

variable "addon_versions" {
  description = "Managed add-on version pins keyed by add-on name; an unpinned add-on takes the EKS default for cluster_version. Pin from the addon_versions output after the first apply"
  type        = map(string)

  validation {
    condition     = alltrue([for name in keys(var.addon_versions) : contains(keys(local.addons), name)])
    error_message = "addon_versions keys must be vpc-cni, kube-proxy, eks-pod-identity-agent, coredns or aws-secrets-store-csi-driver-provider."
  }
}

variable "admin_principal_arns" {
  description = "IAM users or roles, besides the Terraform runner, that get AmazonEKSClusterAdminPolicy on the cluster; the owner's ARNs go in the tier's git-ignored secrets.auto.tfvars, which overrides the empty list in terraform.tfvars"
  type        = list(string)

  validation {
    condition     = alltrue([for a in var.admin_principal_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(role|user)/.+", a))])
    error_message = "admin_principal_arns takes IAM role or user ARNs only; EKS access entries do not accept the root user."
  }
}
