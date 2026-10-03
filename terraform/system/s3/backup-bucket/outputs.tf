output "bucket_name" {
  description = "Name of the backup bucket"
  value       = module.backup_bucket.s3_name
}

output "bucket_arn" {
  description = "ARN of the backup bucket"
  value       = module.backup_bucket.arn
}

output "replica_bucket_name" {
  description = "Name of the replica bucket in the second region"
  value       = module.backup_bucket_replication.replica_bucket
}

output "replica_bucket_arn" {
  description = "ARN of the replica bucket in the second region"
  value       = module.backup_bucket_replication.replica_bucket_arn
}
