#Backup bucket, versioned and replicated to the second region.

module "backup_bucket" {
  source                  = "../../../modules/s3/s3-v1.1.1"
  enable_sse              = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  bucket            = var.backup_bucket_name
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Enabled"
  sse_algorithm     = "AES256"
}

module "backup_bucket_replication" {
  source = "../../../modules/s3/s3-v1.1.1/replication"
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  bucket                   = module.backup_bucket.s3_name
  bucket_arn               = module.backup_bucket.arn
  source_versioning_status = module.backup_bucket.versioning_status
}
