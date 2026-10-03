variable "chart_version" {
  description = "aws-load-balancer-controller Helm chart version, an exact X.Y.Z pin; files/crds/ must hold the same version's crds/"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be an exact X.Y.Z pin, e.g. 3.5.0; a range lets the chart move without a commit."
  }
}
