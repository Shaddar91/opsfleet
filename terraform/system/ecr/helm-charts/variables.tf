variable "repository_name" {
  description = "Name of the chart repository, <namespace>/<chart name>: helm push appends the chart name to the oci:// namespace"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]*/[a-z0-9][a-z0-9._-]*$", var.repository_name))
    error_message = "repository_name must be <namespace>/<chart name>, e.g. helm-charts/of-api, so helm push oci://<registry>/<namespace> lands in it."
  }
}

variable "force_delete" {
  description = "Let destroy delete the repository while it still holds charts; a change takes effect only after an apply"
  type        = bool
}
