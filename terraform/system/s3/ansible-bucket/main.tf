#Ansible bucket: instance user-data pulls the roles tarball and the playbook from here at boot.

module "ansible_bucket" {
  source = "../../../modules/s3/s3-v1.1.1"

  bucket            = var.ansible_bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = "BucketOwnerEnforced"
  bucket_versioning = "Enabled"
  enable_sse        = true
  sse_algorithm     = "AES256"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  noncurrent_days           = var.noncurrent_days
  newer_noncurrent_versions = var.newer_noncurrent_versions
  abort_multipart_days      = var.abort_multipart_days
}
