module "alb_log_bucket" {
  source                  = "../../s3/s3-v1.1-merged"
  bucket                  = local.bucket
  acl                     = "log-delivery-write"
  bucket_versioning       = var.bucket_versioning
  object_ownership        = var.object_ownership
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  policy = templatefile(
    "${path.module}/files/alb_s3.json",
    {
      bucket     = local.bucket
      account_id = data.aws_caller_identity.current.account_id
      alb_region = var.alb_region
    }
  )
  lifecycle_rule = true
  expire_after   = var.expire_days
}


#----------------------------------------------------------
#WAF Kinesis Firehose Delivery Stream
#Only created when enable_waf = true
#----------------------------------------------------------

resource "aws_kinesis_firehose_delivery_stream" "main" {
  count       = var.enable_waf ? 1 : 0
  name        = "aws-waf-logs-${var.environment}-${var.application}"
  destination = "extended_s3"

  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn   = module.firehose_role[0].role.arn
    bucket_arn = module.alb_log_bucket.arn
    prefix     = "waf-logs"
  }
}
