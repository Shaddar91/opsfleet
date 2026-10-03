locals {
  web_fqdn          = "${var.web_subdomain}.${local.public_zone_domain_name}"
  web_bucket_arn    = "arn:${data.aws_partition.current.partition}:s3:::${var.web_bucket_name}"
  log_bucket_arn    = "arn:${data.aws_partition.current.partition}:s3:::${var.log_bucket_name}"
  api_base_url      = "https://${var.api_subdomain}.${local.public_zone_domain_name}"
  load_api_base_url = "https://${var.load_subdomain}.${local.public_zone_domain_name}"
  build_values = merge(var.web_build_values, {
    VITE_API_BASE_URL      = local.api_base_url
    VITE_LOAD_API_BASE_URL = local.load_api_base_url
  })
}
