variable "application" {
  description = "Name part of every Aurora resource: <environment>-<application>-aurora-cluster, -instance-1, -sg, -subnet-group, -global, -master"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version at creation; the parameter group family follows it"
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

variable "database_name" {
  description = "Database created with the cluster"
  type        = string
}

variable "master_username" {
  description = "Master username; the module generates its password and keeps both in the master user secret"
  type        = string
}

variable "master_user_secret_replica_regions" {
  description = "Regions the master user secret is replicated to"
  type        = list(string)
}

variable "deletion_protection" {
  description = "Refuse to delete the cluster until this is set false and applied"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Delete without a final snapshot"
  type        = bool
}

variable "backup_retention_period" {
  description = "Days of automated backups, 1-35"
  type        = number
}
