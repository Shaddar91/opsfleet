variable "cluster_name" {
  description = "EKS cluster the Pod Identity association binds the operator role to"
  type        = string
}

variable "chart_version" {
  description = "Version of the keda Helm chart"
  type        = string
}
