output "bucket_name" {
  description = "Name of the Ansible bucket"
  value       = module.ansible_bucket.s3_name
}

output "bucket_arn" {
  description = "ARN of the Ansible bucket"
  value       = module.ansible_bucket.arn
}

output "bucket_region" {
  description = "Region of the Ansible bucket; stacks in other regions read and write it there"
  value       = var.region
}
