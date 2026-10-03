output "bucket_name" {
  description = "Name of the state bucket"
  value       = var.create_state_bucket ? aws_s3_bucket.state[0].bucket : data.aws_s3_bucket.existing[0].bucket
}

output "bucket_arn" {
  description = "ARN of the state bucket"
  value       = var.create_state_bucket ? aws_s3_bucket.state[0].arn : data.aws_s3_bucket.existing[0].arn
}
