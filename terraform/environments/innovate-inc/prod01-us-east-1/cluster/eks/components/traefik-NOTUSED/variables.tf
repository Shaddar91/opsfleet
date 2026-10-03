variable "chart_version" {
  description = "traefik Helm chart version, an exact X.Y.Z pin; files/crds/ must hold the same version's crds/traefik.io_*.yaml"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be an exact X.Y.Z pin, e.g. 41.6.0; a range lets the chart move without a commit."
  }
}
