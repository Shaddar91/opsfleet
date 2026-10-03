output "bucket_name" {
  description = "Name of the private site bucket the of-web CI uploads the build to"
  value       = module.web_bucket.s3_name
}

output "bucket_arn" {
  description = "ARN of the site bucket, for the CI deploy role's list and object permissions"
  value       = module.web_bucket.arn
}

output "distribution_id" {
  description = "Id of the CloudFront distribution the CI invalidates after a deploy"
  value       = module.cloudfront.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution, the resource of the CI role's invalidation permissions"
  value       = module.cloudfront.arn
}

output "distribution_domain" {
  description = "CloudFront domain name of the distribution, for a smoke test before DNS resolves"
  value       = module.cloudfront.domain_name
}

output "web_fqdn" {
  description = "Hostname serving the site; the zone apex 301s here"
  value       = local.web_fqdn
}

output "web_acl_arn" {
  description = "ARN of the CLOUDFRONT-scope WAF web ACL attached to the distribution"
  value       = module.waf.web_acl_arn
}

output "log_bucket_name" {
  description = "Name of the bucket receiving the distribution's standard logging v2 access logs; null when enable_access_logs is false"
  value       = one(module.log_bucket[*].s3_name)
}

#output "web_build_secret_arn" {
#  description = "ARN the CI role may read and the GitHub secret WEB_BUILD_SECRET_ARN carries"
#  value       = module.web_build_secret.secrets_manager.arn
#}
