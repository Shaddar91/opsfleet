variable "namespaces" {
  description = "Namespaces this stack owns, keyed by name, each with optional labels and annotations; the cluster's own default and kube-* namespaces never go here"
  type = map(object({
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for name in keys(var.namespaces) : can(regex("^[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?$", name)) && name != "default" && !startswith(name, "kube-")])
    error_message = "namespaces keys must be DNS-1123 labels of at most 63 lowercase letters, digits or hyphens, and never default or kube-*: the stack would adopt a cluster namespace and destroy would try to delete it."
  }
}
