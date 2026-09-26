resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  tags = {
    Name = var.bucket
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_policy     = var.block_public_policy
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.object_ownership == "ObjectWriter" ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket
  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count         = var.enable_logging ? 1 : 0
  bucket        = aws_s3_bucket.bucket.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = var.lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    id = "delete-noncurrent-versions-and-delete-markers"
    filter {
      prefix = var.prefix
    }
    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      noncurrent_days = var.expire_after
    }
    status = "Enabled"
  }
  rule {
    id = "expire-objects"
    filter {
      prefix = var.prefix
    }
    expiration {
      days = var.expire_after
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.policy == null ? templatefile(
    "${path.module}/files/bucket_policy.json",
    {
      bucket = var.bucket
    }
  ) : var.policy
}