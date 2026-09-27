variable "chart_version" {
  description = "karpenter and karpenter-crd Helm chart version, one exact X.Y.Z pin for both; karpenter-aws/files/policies must come from the same release tag"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be an exact X.Y.Z pin, e.g. 1.14.1; a range lets the chart move without a commit."
  }
}

variable "application" {
  description = "application tag on the instances, volumes and launch templates Karpenter creates"
  type        = string
}

variable "x86_cpu_limit" {
  description = "vCPU cap of the x86 NodePool: Karpenter launches no x86 node that would take the pool past it"
  type        = number
  default     = 100

  validation {
    condition     = var.x86_cpu_limit >= 0
    error_message = "x86_cpu_limit is a vCPU count, 0 or more; 0 stops the pool from launching nodes."
  }
}

variable "graviton_cpu_limit" {
  description = "vCPU cap of the Graviton NodePool: Karpenter launches no arm64 node that would take the pool past it"
  type        = number
  default     = 50

  validation {
    condition     = var.graviton_cpu_limit >= 0
    error_message = "graviton_cpu_limit is a vCPU count, 0 or more; 0 stops the pool from launching nodes."
  }
}
