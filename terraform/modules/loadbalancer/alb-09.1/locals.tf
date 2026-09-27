locals {
  bucket = var.log_bucket_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
