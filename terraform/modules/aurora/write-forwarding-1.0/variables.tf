variable "region" {
  description = "Region of the secondary cluster"
  type        = string
}

variable "cluster_identifier" {
  description = "Identifier of the secondary cluster that forwards writes to the global database's writer"
  type        = string
}
