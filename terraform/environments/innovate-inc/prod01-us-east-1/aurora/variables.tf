variable "application" {
  description = "Name part of every Aurora resource: <environment>-<application>-aurora-cluster, -instance-1, -sg, -subnet-group, -global, -master"
  type        = string
}

variable "create_global_cluster" {
  description = "Wrap the cluster into the global database the us-west-2 stack joins; needs instance_class db.r6g.large or larger"
  type        = bool
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
  description = "Master username, kept with the password in the master user secret"
  type        = string
}

variable "aurora_master_password" {
  description = "Master user password, set on the cluster and written to the master user secret; valued in the tier's secrets.auto.tfvars"
  type        = string
  sensitive   = true
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
