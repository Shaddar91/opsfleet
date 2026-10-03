data "aws_kms_key" "source" {
  count  = var.source_kms == null ? 1 : 0
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "replica" {
  provider = aws.replica
  key_id   = "alias/aws/s3"
}
