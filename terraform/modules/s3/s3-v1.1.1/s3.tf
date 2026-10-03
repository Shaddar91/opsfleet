resource "aws_s3_bucket" "bucket" {
  bucket              = var.bucket
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock
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
  count  = var.acl != null && var.object_ownership != "BucketOwnerEnforced" ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_ownership_controls.bucket,
    aws_s3_bucket_public_access_block.public_access
  ]
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
  count  = var.lifecycle_rule || var.noncurrent_days != null || var.abort_multipart_days != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket

  dynamic "rule" {
    for_each = var.lifecycle_rule ? [1] : []
    content {
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
  }

  dynamic "rule" {
    for_each = var.lifecycle_rule ? [1] : []
    content {
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

  dynamic "rule" {
    for_each = var.lifecycle_rule && var.transition_days != null ? [1] : []
    content {
      id = "transition-to-${lower(var.transition_storage_class)}"
      filter {
        prefix = var.prefix
      }
      transition {
        days          = var.transition_days
        storage_class = var.transition_storage_class
      }
      noncurrent_version_transition {
        noncurrent_days = var.transition_days
        storage_class   = var.transition_storage_class
      }
      status = "Enabled"
    }
  }

  dynamic "rule" {
    for_each = var.noncurrent_days != null ? [1] : []
    content {
      id = "delete-noncurrent-versions"
      filter {
        prefix = var.prefix
      }
      expiration {
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration {
        noncurrent_days           = var.noncurrent_days
        newer_noncurrent_versions = var.newer_noncurrent_versions
      }
      status = "Enabled"
    }
  }

  dynamic "rule" {
    for_each = var.abort_multipart_days != null ? [1] : []
    content {
      id = "abort-incomplete-multipart-uploads"
      filter {
        prefix = var.prefix
      }
      abort_incomplete_multipart_upload {
        days_after_initiation = var.abort_multipart_days
      }
      status = "Enabled"
    }
  }

  depends_on = [aws_s3_bucket_versioning.bucket_versioning]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = var.enable_sse ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "bucket" {
  count  = var.object_lock && var.object_lock_mode != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    default_retention {
      mode  = var.object_lock_mode
      years = var.retention_years
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.policy == null ? templatefile(
    "${path.module}/files/bucket_policy.json",
    {
      BUCKET = var.bucket
    }
  ) : var.policy
  depends_on = [
    aws_s3_bucket_public_access_block.public_access,
    aws_s3_bucket_ownership_controls.bucket
  ]
}

resource "aws_s3_object" "main" {
  for_each    = var.objects == null ? toset([]) : fileset(var.objects.path, "**")
  bucket      = aws_s3_bucket.bucket.bucket
  key         = join("/", slice(split("/", "${var.objects.path}${each.value}"), var.objects.index, length(split("/", "${var.objects.path}${each.value}"))))
  source      = "${var.objects.path}${each.value}"
  source_hash = filemd5("${var.objects.path}${each.value}")
}
