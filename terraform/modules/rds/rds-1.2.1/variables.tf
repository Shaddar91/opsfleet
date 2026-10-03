variable "environment" {
  type        = string
  description = "Environment name, the first part of every resource name"
}

variable "application" {
  type        = string
  description = "Application name, the second part of every resource name and the default internal record name"
}

variable "identifier" {
  type        = string
  default     = null
  description = "Instance identifier; null gives <environment>-<application>. Replicas append -ro, -ro1, ..."
}

variable "vpc_id" {
  type        = string
  description = "VPC of the module security group"
}

variable "internal_subnets" {
  type        = list(string)
  description = "Subnet IDs of the DB subnet group, in at least two availability zones"
}

variable "availability_zone" {
  type        = string
  default     = null
  description = "AZ of a single-AZ primary and of the first replica; must be null when multi_az is true"
}

variable "multi_az" {
  type        = bool
  description = "Multi-AZ primary"
}

variable "engine" {
  type        = string
  description = "RDS engine, e.g. postgres, mysql, mariadb, sqlserver-se"
}

variable "engine_version" {
  type        = string
  description = "Engine version; give a prefix such as \"16\" when auto_minor_version_upgrade is true"
}

variable "instance_class" {
  type        = string
  description = "Instance class of the primary and the replicas"
}

variable "port" {
  type        = number
  description = "Database port, also the port of the security group ingress rules"
}

variable "parameter_family" {
  type        = string
  description = "Parameter group family of both parameter groups, e.g. postgres16"
}

variable "db_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default     = []
  nullable    = false
  description = "Primary parameter group entries; apply_method null means immediate, static parameters need pending-reboot"
}

variable "database_name" {
  type        = string
  default     = null
  description = "Database created with the instance; null creates none"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "manage_master_user_password" {
  type        = bool
  default     = true
  nullable    = false
  description = "RDS keeps the master password in Secrets Manager. AWS then refuses read replicas on every engine but SQL Server and Db2; set false and pass password_wo for those"
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key of the managed master user secret; null uses the account's Secrets Manager key"
}

variable "password_wo" {
  type        = string
  default     = null
  sensitive   = true
  ephemeral   = true
  description = "Master password when manage_master_user_password is false; write-only, never stored in plan or state"
}

variable "password_wo_version" {
  type        = number
  default     = 1
  nullable    = false
  description = "Change it to push a new password_wo"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "IAM database authentication on the primary and the replicas"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage in GiB"
}

variable "max_allocated_storage" {
  type        = number
  default     = 0
  nullable    = false
  description = "Storage autoscaling ceiling in GiB; 0 turns autoscaling off"
}

variable "storage_type" {
  type        = string
  default     = "gp2"
  nullable    = false
  description = "Storage type: gp2, gp3, io1, io2 or standard"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  nullable    = false
  description = "Encrypt storage at rest"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for storage encryption; null uses the aws/rds key"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  nullable    = false
  description = "Days of automated backups, 0-35; must be above 0 while read replicas exist"
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  nullable    = false
  description = "Copy instance tags to snapshots"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  nullable    = false
  description = "Delete without a final snapshot"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Final snapshot name; null gives <identifier>-final"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  nullable    = false
  description = "Refuse to delete the primary until this is set false and applied"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  nullable    = false
  description = "Apply modifications now instead of in the next maintenance window, on the primary and the replicas"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = false
  nullable    = false
  description = "Minor engine upgrades in the maintenance window on the primary"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Performance Insights on the primary"
}

variable "monitoring_interval" {
  type        = number
  default     = 0
  nullable    = false
  description = "Enhanced Monitoring interval in seconds: 0, 1, 5, 10, 15, 30 or 60. Above 0 the module creates the monitoring role"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  nullable    = false
  description = "Public IP on the primary"
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

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Extra security groups attached next to the module security group"
}

variable "read_replica_count" {
  type        = number
  default     = 0
  nullable    = false
  description = "Read replicas <identifier>-ro, <identifier>-ro1, ..."

  validation {
    condition     = var.read_replica_count >= 0 && floor(var.read_replica_count) == var.read_replica_count
    error_message = "read_replica_count must be a whole number, 0 or more."
  }
}

variable "replica_additional_availability_zone" {
  type        = string
  default     = null
  description = "AZ of the second and later replicas; null keeps them in availability_zone. Must be null when replica_multi_az is true"
}

variable "replica_db_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default     = []
  nullable    = false
  description = "Replica parameter group entries; replicas do not inherit db_parameters"
}

variable "replica_publicly_accessible" {
  type        = bool
  default     = false
  nullable    = false
  description = "Public IP on the replicas"
}

variable "replica_backup_retention_period" {
  type        = number
  default     = 0
  nullable    = false
  description = "Days of automated backups on each replica"
}

variable "replica_multi_az" {
  type        = bool
  default     = false
  nullable    = false
  description = "Multi-AZ replicas"
}

variable "replica_auto_minor_version_upgrade" {
  type        = bool
  default     = false
  nullable    = false
  description = "Minor engine upgrades in the maintenance window on the replicas"
}

variable "replica_performance_insights_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Performance Insights on the replicas"
}

variable "internal_dns" {
  type = object({
    zone_id = string
    name    = optional(string)
    ttl     = optional(number, 300)
  })
  default     = null
  description = "Private hosted zone for the CNAMEs <name> and <name>-ro, <name>-ro1, ...; name defaults to application. null creates no record"

  validation {
    condition     = var.internal_dns == null || try(var.internal_dns.zone_id != "", true)
    error_message = "internal_dns.zone_id must not be empty; pass internal_dns = null for no records."
  }
}
