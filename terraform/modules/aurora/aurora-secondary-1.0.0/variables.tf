variable "environment" {
  type        = string
  description = "Environment name, the first part of every resource name"
}

variable "application" {
  type        = string
  description = "Application name, the second part of every resource name"
}

variable "vpc_id" {
  type        = string
  description = "VPC of the module security group"
}

variable "internal_subnets" {
  type        = list(string)
  description = "Subnet IDs of the DB subnet group, in at least two availability zones"
}

variable "global_cluster_identifier" {
  type        = string
  description = "Global database the cluster joins as a secondary; it supplies the master user and the database"
}

variable "source_region" {
  type        = string
  description = "Region of the global database's primary cluster, the source region of an encrypted secondary"
}

variable "engine" {
  type        = string
  description = "Aurora engine of the global database: aurora-postgresql or aurora-mysql"

  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be aurora-postgresql or aurora-mysql."
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version of the global database at creation; later changes are ignored"
}

variable "family" {
  type        = string
  description = "Parameter group family of the cluster parameter group, e.g. aurora-postgresql17"
}

variable "port" {
  type        = number
  description = "Database port, also the port of the security group ingress rules"
}

variable "enable_global_write_forwarding" {
  type        = bool
  default     = false
  nullable    = false
  description = "Forward writes sent to this cluster to the writer of the global database's primary cluster"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  nullable    = false
  description = "Encrypt cluster storage at rest, set as the global database is; changing it replaces the cluster"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN in this region for storage encryption; null uses this region's aws/rds key"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  nullable    = false
  description = "Delete without a final snapshot; otherwise the snapshot is <cluster identifier>-final"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  nullable    = false
  description = "Refuse to delete the cluster until this is set false and applied"
}

variable "cluster_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default     = []
  nullable    = false
  description = "Cluster parameter group entries; apply_method null means immediate, static parameters need pending-reboot"
}

variable "serverlessv2_scaling" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "Serverless v2 capacity range in ACUs; null is a provisioned cluster"

  validation {
    condition = var.serverlessv2_scaling == null || try(
      var.serverlessv2_scaling.min_capacity >= 0 &&
      var.serverlessv2_scaling.min_capacity <= var.serverlessv2_scaling.max_capacity &&
      var.serverlessv2_scaling.max_capacity >= 1 &&
      var.serverlessv2_scaling.max_capacity <= 256 &&
      floor(var.serverlessv2_scaling.min_capacity * 2) == var.serverlessv2_scaling.min_capacity * 2 &&
      floor(var.serverlessv2_scaling.max_capacity * 2) == var.serverlessv2_scaling.max_capacity * 2,
      false
    )
    error_message = "serverlessv2_scaling needs 0 <= min_capacity <= max_capacity and 1 <= max_capacity <= 256, both in steps of 0.5 ACU."
  }
}

variable "instance_count" {
  type        = number
  default     = 1
  nullable    = false
  description = "Cluster instances <environment>-<application>-aurora-instance-1, -2, ..."

  validation {
    condition     = var.instance_count >= 1 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count must be a whole number, 1 or more."
  }
}

variable "instance_class" {
  type        = string
  default     = null
  description = "Instance class of every cluster instance; null gives db.serverless when serverlessv2_scaling is set and fails the plan otherwise"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Security groups the module security group admits on the database port"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "IPv4 CIDR blocks the module security group admits on the database port"
}
