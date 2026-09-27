#prod01-us frontend: private S3 site bucket behind CloudFront (OAC, SPA fallback, security headers), access logs v2 to a log bucket.

locals {
  web_fqdn       = "${var.web_subdomain}.${local.public_zone_domain_name}"
  web_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.web_bucket_name}"
  log_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.log_bucket_name}"
}

module "web_bucket" {
  source = "../../../modules/s3/s3-v1.1.1"

  bucket            = var.web_bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Enabled"
  enable_sse        = true
  sse_algorithm     = "AES256"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  #never lifecycle_rule here: it also expires current objects, the live build
  noncurrent_days           = var.web_noncurrent_days
  newer_noncurrent_versions = var.web_newer_noncurrent_versions
  abort_multipart_days      = var.web_abort_multipart_days

  policy = templatefile("${path.module}/files/policies/web-bucket.json.tftpl", {
    bucket_arn       = local.web_bucket_arn
    distribution_arn = module.cloudfront.arn
  })
}

module "log_bucket" {
  source = "../../../modules/s3/s3-v1.1.1"

  bucket            = var.log_bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Disabled"
  enable_sse        = true
  sse_algorithm     = "AES256"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rule = true
  expire_after   = var.log_expire_days

  #must keep the delivery.logs write statement: AWS appends it at delivery creation and the next apply would strip it
  policy = templatefile("${path.module}/files/policies/log-bucket.json.tftpl", {
    bucket_arn = local.log_bucket_arn
    account_id = data.aws_caller_identity.current.account_id
    partition  = data.aws_partition.current.partition
  })
}

module "cloudfront" {
  source = "../../../modules/cloudfront/cloudfront-1.2.1"

  environment = var.environment
  domain      = local.web_fqdn
  aliases     = [local.web_fqdn]

  origin_type         = "s3-oac"
  s3_endpoint         = module.web_bucket.bucket_regional_domain_name
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  cache_policy_id     = data.aws_cloudfront_cache_policy.caching_optimized.id

  custom_error_responses = [
    for code in [403, 404] : {
      error_code            = code
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    }
  ]

  security_headers = {
    hsts_max_age_sec        = 31536000
    hsts_include_subdomains = true
    hsts_preload            = false
    content_type_options    = true
    frame_option            = "DENY"
    referrer_policy         = "strict-origin"
    override                = true
  }

  price_class              = "PriceClass_100"
  minimum_protocol_version = "TLSv1.2_2021"
  acm_certificate_arn      = module.cert.validated_arn
  web_acl_id               = module.waf.web_acl_arn

  enable_logging = true
  log_bucket_arn = module.log_bucket.arn
}
