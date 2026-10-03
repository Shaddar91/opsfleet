#Artifact bucket: CI publishes of-web builds here.

module "artifact_bucket" {
  source                  = "../../../modules/s3/s3-v1.1.1"
  enable_sse              = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  bucket            = var.artifact_bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Enabled"
  sse_algorithm     = "AES256"

  lifecycle_rule = var.lifecycle_rule
  expire_after   = var.expire_after
  prefix         = var.prefix

  noncurrent_days           = var.noncurrent_days
  newer_noncurrent_versions = var.newer_noncurrent_versions
  abort_multipart_days      = var.abort_multipart_days
}
