data "aws_kms_alias" "rds" {
  count = var.storage_encrypted && var.kms_key_id == null ? 1 : 0
  name  = "alias/aws/rds"
}
