#Aurora cluster with its subnet group, cluster parameter group and IAM role associations.

resource "aws_rds_cluster" "main" {
  cluster_identifier                  = local.cluster_identifier
  engine                              = var.engine
  engine_version                      = var.engine_version
  global_cluster_identifier           = var.create_global_cluster ? aws_rds_global_cluster.main[0].id : null
  availability_zones                  = var.availability_zones
  database_name                       = var.database_name
  master_username                     = var.master_username
  manage_master_user_password         = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_password_wo                  = var.manage_master_user_password ? null : local.master_password
  master_password_wo_version          = var.manage_master_user_password ? null : var.master_password_wo_version
  port                                = var.port
  db_subnet_group_name                = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.main.name
  vpc_security_group_ids              = concat([aws_security_group.main.id], var.vpc_security_group_ids)
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.storage_encrypted ? var.kms_key_id : null
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${local.cluster_identifier}-final")
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling == null ? [] : [var.serverlessv2_scaling]

    content {
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      seconds_until_auto_pause = serverlessv2_scaling_configuration.value.seconds_until_auto_pause
    }
  }

  tags = {
    Name        = local.cluster_identifier
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [engine_version, global_cluster_identifier, replication_source_identifier]

    precondition {
      condition     = (var.manage_master_user_password ? 1 : 0) + (var.master_password_wo == null ? 0 : 1) + (var.create_master_user_secret ? 1 : 0) == 1
      error_message = "Credentials: pick exactly one of manage_master_user_password = true (RDS-managed secret), master_password_wo (caller password) or create_master_user_secret = true (module secret); create_master_user_secret and master_password_wo need manage_master_user_password = false."
    }
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

resource "aws_rds_cluster_role_association" "main" {
  count                 = length(var.rds_roles)
  db_cluster_identifier = aws_rds_cluster.main.id
  feature_name          = var.rds_roles[count.index].feature_name
  role_arn              = var.rds_roles[count.index].role_arn
}
