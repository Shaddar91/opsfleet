variable "application" {
  description = "Name part of every Aurora resource: <environment>-<application>-aurora-cluster, -instance-1, -sg, -subnet-group, -parameter-group"
  type        = string
}

variable "primary_environment" {
  description = "Environment of the global database's primary aurora stack, the environment segment of its state key"
  type        = string
}

variable "instance_class" {
  description = "Instance class of the cluster instance"
  type        = string
}

variable "serverlessv2_scaling" {
  description = "Serverless v2 capacity range in ACUs of db.serverless instances; null for a provisioned class"
  type = object({
    min_capacity = number
    max_capacity = number
  })
}

variable "deletion_protection" {
  description = "Refuse to delete the cluster until this is set false and applied"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Delete without a final snapshot"
  type        = bool
}

variable "aurora_master_password" {
  description = "Master user password of the global database, written to this region's master user secret; valued in the tier's secrets.auto.tfvars"
  type        = string
  sensitive   = true
}

variable "write_forwarding" {
  description = "Forward writes sent to this read-only copy to the global database's writer: the aurora/forwarding tier turns it on, and the backends connect to the reader endpoint instead of the proxy"
  type        = bool
}
