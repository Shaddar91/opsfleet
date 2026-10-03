output "bucket_name" {
  description = "Name of the artifact bucket"
  value       = module.artifact_bucket.s3_name
}

output "bucket_arn" {
  description = "ARN of the artifact bucket"
  value       = module.artifact_bucket.arn
}
