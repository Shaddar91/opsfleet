variable "chart_version" {
  description = "metrics-server Helm chart version, an exact X.Y.Z pin"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be an exact X.Y.Z pin, e.g. 3.14.0; a range lets the chart move without a commit."
  }
}
