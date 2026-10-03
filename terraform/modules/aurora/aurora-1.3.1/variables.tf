variable "environment" {
  type        = string
  description = "Environment name, the first part of every resource name"
}

variable "application" {
  type        = string
  description = "Application name, the second part of every resource name and the default internal record name"
}

variable "vpc_id" {
  type        = string
  description = "VPC of the module security group"
}

variable "internal_subnets" {
  type        = list(string)
  description = "Subnet IDs of the DB subnet group, in at least two availability zones"
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "AZs of the cluster storage; null lets AWS pick three. A list shorter than the three AWS assigns replaces the cluster on the next apply"

  validation {
    condition     = var.availability_zones == null || try(length(var.availability_zones) <= 3, false)
    error_message = "availability_zones takes at most 3 zones."
  }
}

variable "engine" {
  type        = string
  default     = "aurora-postgresql"
  nullable    = false
  description = "Aurora engine: aurora-postgresql or aurora-mysql"

  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be aurora-postgresql or aurora-mysql."
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version at creation; later changes are ignored, so a major upgrade needs the ignore_changes on engine_version lifted"
}

variable "family" {
  type        = string
  description = "Parameter group family of the cluster and instance parameter groups, e.g. aurora-postgresql16"
}

variable "port" {
  type        = number
  description = "Database port, also the port of the security group ingress rules"
}

variable "create_global_cluster" {
  type        = bool
  default     = false
  nullable    = false
  description = "Create the global database <environment>-<application>-aurora-global from this cluster, on the first apply or on a later one; the instances must run a class that supports global databases (db.r6g.large or larger, never db.t*)"
}

variable "apply_immediately" {
  type        = bool
  default     = false
  nullable    = false
  description = "Apply cluster and instance modifications now instead of in the next maintenance window"
}

variable "database_name" {
  type        = string
  default     = null
  description = "Database created with the cluster; null creates none"
}

variable "master_username" {
  type        = string
  description = "Master username"
}

variable "manage_master_user_password" {
  type        = bool
  default     = true
  nullable    = false
  description = "RDS keeps the master password in Secrets Manager; set false and pass master_password_wo for a caller password, or set create_master_user_secret"
}

variable "create_master_user_secret" {
  type        = bool
  default     = false
  nullable    = false
  description = "Generate the master password and keep it with the username in the module secret <environment>-<application>-aurora-master; needs manage_master_user_password = false and no master_password_wo"
}

variable "master_user_secret_replica_regions" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Regions the module secret is replicated to, with create_master_user_secret"
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key of the RDS-managed master user secret; null uses the account's Secrets Manager key"
}

variable "master_password_wo" {
  type        = string
  default     = null
  sensitive   = true
  ephemeral   = true
  description = "Caller master password, with manage_master_user_password and create_master_user_secret false; write-only, never stored in plan or state"
}

variable "master_password_wo_version" {
  type        = number
  default     = 1
  nullable    = false
  description = "Change it to push a new master password: master_password_wo, or with create_master_user_secret a newly generated one to the cluster and the module secret"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "IAM database authentication"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  nullable    = false
  description = "Encrypt cluster storage at rest; changing it replaces the cluster"
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
  description = "Days of automated backups, 1-35"
}

variable "preferred_backup_window" {
  type        = string
  default     = "05:00-07:00"
  nullable    = false
  description = "Daily backup window in UTC, hh24:mi-hh24:mi"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:07:30-sun:09:30"
  nullable    = false
  description = "Weekly cluster maintenance window in UTC, ddd:hh24:mi-ddd:hh24:mi"
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  nullable    = false
  description = "Copy cluster tags to snapshots"
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
  description = "Final snapshot name; null gives <cluster identifier>-final"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  nullable    = false
  description = "Refuse to delete the cluster until this is set false and applied"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Log types exported to CloudWatch Logs, e.g. postgresql for Aurora PostgreSQL; audit, error, general, slowquery for Aurora MySQL"
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

variable "instance_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default     = null
  description = "Instance parameter group entries; null creates no group and the instances use default.<family>"
}

variable "rds_roles" {
  type = list(object({
    role_arn     = string
    feature_name = optional(string)
  }))
  default     = []
  nullable    = false
  description = "IAM roles associated with the cluster; feature_name from the engine version's SupportedFeatureNames, null where it lists none"
}

variable "serverlessv2_scaling" {
  type = object({
    min_capacity             = number
    max_capacity             = number
    seconds_until_auto_pause = optional(number)
  })
  default     = null
  description = "Serverless v2 capacity range in ACUs; null is a provisioned cluster. min_capacity 0 pauses idle instances after seconds_until_auto_pause (300-86400, AWS default 300)"

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

  validation {
    condition     = var.serverlessv2_scaling == null || try(var.serverlessv2_scaling.seconds_until_auto_pause == null || var.serverlessv2_scaling.min_capacity == 0, false)
    error_message = "serverlessv2_scaling.seconds_until_auto_pause needs min_capacity = 0: instances pause only at 0 ACUs, and the provider drops the value otherwise."
  }
}

variable "instance_count" {
  type        = number
  default     = 1
  nullable    = false
  description = "Cluster instances <environment>-<application>-aurora-instance-1, -2, ...; one is the writer, the rest are readers"

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

variable "publicly_accessible" {
  type        = bool
  default     = false
  nullable    = false
  description = "Public IP on the instances"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  nullable    = false
  description = "Minor engine upgrades in the maintenance window"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Performance Insights on the instances"
}

variable "monitoring_interval" {
  type        = number
  default     = 60
  nullable    = false
  description = "Enhanced Monitoring interval in seconds: 0, 1, 5, 10, 15, 30 or 60. Above 0 the instances use monitoring_role or a role the module creates"
}

variable "monitoring_role" {
  type = object({
    arn = string
  })
  default     = null
  description = "Existing Enhanced Monitoring role; null creates one when monitoring_interval is above 0. An object, so an ARN unknown at plan keeps the role count known"
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
  description = "Extra security groups attached to the cluster next to the module security group"
}

variable "internal_dns" {
  type = object({
    zone_id = string
    name    = optional(string)
    ttl     = optional(number, 300)
  })
  default     = null
  description = "Private hosted zone for the CNAMEs <name> (writer endpoint) and <name>-ro (reader endpoint); name defaults to application. null creates no record"

  validation {
    condition     = var.internal_dns == null || try(var.internal_dns.zone_id != "", true)
    error_message = "internal_dns.zone_id must not be empty; pass internal_dns = null for no records."
  }
}
