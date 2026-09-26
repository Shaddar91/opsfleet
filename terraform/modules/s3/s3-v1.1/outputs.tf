output "arn" {
  value = aws_s3_bucket.bucket.arn
}
output "s3" {
  value = aws_s3_bucket.bucket
}

output "s3_ep" {
  value = var.enable_website ? aws_s3_bucket_website_configuration.bucket[0].website_endpoint : null
}


output "s3_name" {
  value = aws_s3_bucket.bucket.bucket
}