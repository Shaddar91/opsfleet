data "aws_kms_key" "source" {
  count  = var.source_kms == null ? 1 : 0
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "replica" {
  provider = aws.replica
  key_id   = "alias/aws/s3"
}

locals {
  replica_bucket = coalesce(var.replica_bucket, "${var.bucket}-replica")
  source_kms     = var.source_kms != null ? var.source_kms : data.aws_kms_key.source[0].arn
  source_region  = split(":", local.source_kms)[3]
  replica_region = split(":", data.aws_kms_key.replica.arn)[3]
}

module "s3_replication_role" {
  source        = "../../../iam/role"
  aws_service   = "s3.amazonaws.com"
  name          = var.bucket
  custom_policy = true
  policy_file = templatefile(
    "${path.module}/files/replication_policy.json",
    {
      source_bucket      = var.bucket_arn
      destination_bucket = aws_s3_bucket.replica.arn
      source_region      = local.source_region
      destination_region = local.replica_region
      source_kms         = local.source_kms
      destination_kms    = data.aws_kms_key.replica.arn
    }
  )
}

resource "aws_s3_bucket" "replica" {
  provider            = aws.replica
  bucket              = local.replica_bucket
  object_lock_enabled = var.object_lock
  tags = {
    Name = local.replica_bucket
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "replica" {
  count    = var.object_lock && var.object_lock_mode != null ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  rule {
    default_retention {
      mode  = var.object_lock_mode
      years = var.retention_years
    }
  }
}

resource "aws_s3_bucket_public_access_block" "replica" {
  provider                = aws.replica
  bucket                  = aws_s3_bucket.replica.id
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  policy = templatefile(
    "${path.module}/../files/bucket_policy.json",
    { bucket = local.replica_bucket }
  )
  depends_on = [aws_s3_bucket_public_access_block.replica]
}

resource "aws_s3_bucket_replication_configuration" "main" {
  bucket = var.bucket
  role   = module.s3_replication_role.role_arn

  rule {
    id     = "cross-region-replication"
    status = "Enabled"
    filter {}
    delete_marker_replication {
      status = "Enabled"
    }
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"
      encryption_configuration {
        replica_kms_key_id = data.aws_kms_key.replica.arn
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.source_versioning_status == "Enabled"
      error_message = "Replication needs bucket_versioning = \"Enabled\" on the source bucket."
    }
  }
  depends_on = [aws_s3_bucket_versioning.replica]
}
