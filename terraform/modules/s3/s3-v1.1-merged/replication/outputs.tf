output "replica_bucket_arn" {
  value = aws_s3_bucket.replica.arn
}

output "replica_bucket" {
  value = aws_s3_bucket.replica.bucket
}

output "replication_role_arn" {
  value = module.s3_replication_role.role_arn
}
