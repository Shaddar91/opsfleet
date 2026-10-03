variable "backup_bucket_name" {
  description = "Name of the backup bucket; export TF_VAR_backup_bucket_name from the env file outside the repo"
  type        = string
}

variable "replica_region" {
  description = "Region of the replica bucket, the second region"
  type        = string
}
