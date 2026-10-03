variable "argocd_namespace" {
  description = "Namespace of the argo-cd release; argocd-configuration puts the credential and argocd-apps there too"
  type        = string
}

variable "argocd_chart_repository" {
  description = "Helm repository of the argo-cd chart"
  type        = string
}

variable "argo_cd_chart_version" {
  description = "argo-cd Helm chart version, an exact X.Y.Z pin"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.argo_cd_chart_version))
    error_message = "argo_cd_chart_version must be an exact X.Y.Z pin, e.g. 10.9.4; a range lets the chart move without a commit."
  }
}

variable "argocd_subdomain" {
  description = "Host label of the Argo CD UI under the public zone's domain_name, on the cluster's shared ALB"
  type        = string
}
