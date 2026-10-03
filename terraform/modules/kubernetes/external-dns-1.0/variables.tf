variable "cluster_name" {
  description = "EKS cluster name; also the txtOwnerId that marks the records this release owns"
  type        = string
}

variable "chart_version" {
  description = "external-dns Helm chart version, an exact X.Y.Z pin"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be an exact X.Y.Z pin, e.g. 1.22.0; a range lets the chart move without a commit."
  }
}

variable "zone_id" {
  description = "Route 53 hosted zone ID; the only zone the role may change"
  type        = string
}

variable "domain_name" {
  description = "Domain external-dns manages records under; may sit below the zone apex"
  type        = string
}

variable "region" {
  description = "AWS region set as AWS_DEFAULT_REGION in the external-dns pod"
  type        = string
}
