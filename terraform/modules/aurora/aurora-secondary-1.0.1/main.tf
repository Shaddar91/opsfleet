#Aurora secondary cluster joined to a global database, with its subnet group and cluster parameter group.

resource "aws_rds_cluster" "main" {
  cluster_identifier              = local.cluster_identifier
  global_cluster_identifier       = var.global_cluster_identifier
  source_region                   = var.storage_encrypted ? var.source_region : null
  engine                          = var.engine
  engine_version                  = var.engine_version
  enable_global_write_forwarding  = var.enable_global_write_forwarding
  port                            = var.port
  db_subnet_group_name            = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  vpc_security_group_ids          = [aws_security_group.main.id]
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.storage_encrypted ? local.kms_key_id : null
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${local.cluster_identifier}-final"
  deletion_protection             = var.deletion_protection

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling == null ? [] : [var.serverlessv2_scaling]

    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  tags = {
    Name        = local.cluster_identifier
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [replication_source_identifier, global_cluster_identifier, engine_version]

    precondition {
      condition     = length(local.cluster_identifier) <= 63
      error_message = "The cluster identifier \"${local.cluster_identifier}\" is longer than the 63 characters RDS allows."
    }
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-${var.application}-aurora-subnet-group"
  subnet_ids = var.internal_subnets

  tags = {
    Name        = "${var.environment}-${var.application}-aurora-subnet-group"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  name   = "${var.environment}-${var.application}-aurora-parameter-group"
  family = var.family

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name        = "${var.environment}-${var.application}-aurora-parameter-group"
    Environment = var.environment
  }
}
