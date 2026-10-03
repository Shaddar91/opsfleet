locals {
  replica_bucket = coalesce(var.replica_bucket, "${var.bucket}-replica")
  source_kms     = var.source_kms != null ? var.source_kms : data.aws_kms_key.source[0].arn
  source_region  = split(":", local.source_kms)[3]
  replica_region = split(":", data.aws_kms_key.replica.arn)[3]
}
