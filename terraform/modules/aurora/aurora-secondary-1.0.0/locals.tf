locals {
  cluster_identifier   = "${var.environment}-${var.application}-aurora-cluster"
  instance_identifiers = [for i in range(var.instance_count) : "${var.environment}-${var.application}-aurora-instance-${i + 1}"]
  instance_class       = var.instance_class != null ? var.instance_class : (var.serverlessv2_scaling != null ? "db.serverless" : null)
  kms_key_id           = var.kms_key_id != null ? var.kms_key_id : one(data.aws_kms_alias.rds[*].target_key_arn)
}
