variable "group_name" {
  description = "IAM group the owner adds developer users to; also names the deploy role <group_name>-deploy-role and both policies"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,52}$", var.group_name))
    error_message = "group_name must be 1-52 letters, digits or + = , . @ _ -: the role name <group_name>-deploy-role must fit IAM's 64 characters."
  }
}

variable "namespaces" {
  description = "Namespaces the deploy role gets AmazonEKSEditPolicy in; the namespaces stack must create them"
  type        = list(string)

  validation {
    condition     = length(var.namespaces) > 0 && alltrue([for ns in var.namespaces : can(regex("^[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?$", ns)) && !startswith(ns, "kube-")])
    error_message = "namespaces must list at least one DNS-1123 name and no kube-* namespace: edit rights in kube-system can run pods as the Karpenter and load balancer controller service accounts and so reach their AWS roles."
  }
}
