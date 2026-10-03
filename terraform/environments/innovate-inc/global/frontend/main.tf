#innovate-inc frontend: S3 website bucket behind CloudFront, readable only with the origin secret the Lambda@Edge stamps; the same function sets the CORS and security headers (SPA fallback, zone apex 301 to web_fqdn), access logs v2 to a log bucket.

module "web_bucket" {
  source                  = "../../../../modules/s3/s3-v1.1.1"
  enable_sse              = true
  enable_website          = true
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false

  bucket            = var.web_bucket_name
  index_document    = "index.html"
  error_document    = "index.html"
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Enabled"
  sse_algorithm     = "AES256"

  #never lifecycle_rule here: it also expires current objects, the live build
  noncurrent_days           = var.web_noncurrent_days
  newer_noncurrent_versions = var.web_newer_noncurrent_versions
  abort_multipart_days      = var.web_abort_multipart_days

  policy = templatefile("${path.module}/files/policies/web-bucket.json", {
    BUCKET_ARN    = local.web_bucket_arn
    ORIGIN_SECRET = var.origin_secret
  })
}

module "log_bucket" {
  source                  = "../../../../modules/s3/s3-v1.1.1"
  count                   = var.enable_access_logs ? 1 : 0
  enable_sse              = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  lifecycle_rule          = true

  bucket            = var.log_bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Disabled"
  sse_algorithm     = "AES256"

  expire_after = var.log_expire_days

  #must keep the delivery.logs write statement: AWS appends it at delivery creation and the next apply would strip it
  policy = templatefile("${path.module}/files/policies/log-bucket.json", {
    BUCKET_ARN = local.log_bucket_arn
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
    PARTITION  = data.aws_partition.current.partition
  })
}

module "cloudfront" {
  source          = "../../../../modules/cloudfront/cloudfront-1.2.3"
  is_ipv6_enabled = false
  enable_logging  = var.enable_access_logs

  environment = var.environment
  domain      = local.web_fqdn
  aliases     = [local.web_fqdn, local.public_zone_domain_name]

  viewer_functions = {
    "viewer-request" = templatefile("${path.module}/files/functions/apex-redirect.js", {
      APEX     = local.public_zone_domain_name
      WEB_FQDN = local.web_fqdn
    })
  }

  origin_type         = "custom"
  s3_endpoint         = module.web_bucket.s3_ep
  default_root_object = "index.html"
  lambda_associations = [
    { event_type = "origin-request", lambda_arn = module.edge.qualified_arn },
    { event_type = "origin-response", lambda_arn = module.edge.qualified_arn },
  ]
  cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

  custom_error_responses = [
    for code in [403, 404] : {
      error_code            = code
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    }
  ]


  price_class              = "PriceClass_100"
  minimum_protocol_version = "TLSv1.2_2021"
  acm_certificate_arn      = module.cert.validated_arn
  web_acl_id               = module.waf.web_acl_arn

  log_bucket_arn = one(module.log_bucket[*].arn)
}
