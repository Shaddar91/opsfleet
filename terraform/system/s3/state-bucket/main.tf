#Bootstrap state bucket: holds every other stack's S3 backend state; this stack's own state stays local, outside the repo.
#create_state_bucket = false reads the account's existing bucket instead, so apply never changes it and destroy never deletes it.

resource "aws_s3_bucket" "state" {
  count = var.create_state_bucket ? 1 : 0

  bucket        = var.state_bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_ownership_controls" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  count                   = var.create_state_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.state[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id
  policy = templatefile("${path.module}/files/policies/tls-only.json", {
    BUCKET_ARN = aws_s3_bucket.state[0].arn
  })

  depends_on = [
    aws_s3_bucket_public_access_block.state,
    aws_s3_bucket_ownership_controls.state
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id

  rule {
    id     = "noncurrent-state"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days           = 90
      newer_noncurrent_versions = 10
    }

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.state]
}
