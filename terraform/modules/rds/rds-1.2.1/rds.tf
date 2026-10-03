#Primary RDS instance with its subnet group and parameter group.

resource "aws_db_instance" "main" {
  identifier                          = local.identifier
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  db_name                             = var.database_name
  username                            = var.username
  manage_master_user_password         = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  password_wo                         = var.manage_master_user_password ? null : var.password_wo
  password_wo_version                 = var.manage_master_user_password ? null : var.password_wo_version
  port                                = var.port
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  storage_type                        = var.storage_type
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.storage_encrypted ? var.kms_key_id : null
  db_subnet_group_name                = aws_db_subnet_group.main.name
  parameter_group_name                = aws_db_parameter_group.main.name
  vpc_security_group_ids              = local.vpc_security_group_ids
  availability_zone                   = var.availability_zone
  multi_az                            = var.multi_az
  publicly_accessible                 = var.publicly_accessible
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backup_retention_period             = var.backup_retention_period
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${local.identifier}-final")
  deletion_protection                 = var.deletion_protection
  apply_immediately                   = var.apply_immediately
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  performance_insights_enabled        = var.performance_insights_enabled
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = var.monitoring_interval > 0 ? module.monitoring_role[0].role_arn : null

  tags = {
    Name        = local.identifier
    Environment = var.environment
  }

  depends_on = [module.monitoring_role]

  lifecycle {
    precondition {
      condition     = var.manage_master_user_password == (var.password_wo == null)
      error_message = "Credentials: keep manage_master_user_password = true with no password_wo, or set it false and pass password_wo."
    }
    precondition {
      condition     = !(var.multi_az && var.availability_zone != null)
      error_message = "availability_zone must be null when multi_az is true: AWS rejects an AZ for a Multi-AZ instance."
    }
    precondition {
      condition     = length(local.identifier) <= 63
      error_message = "The instance identifier \"${local.identifier}\" is longer than the 63 characters RDS allows."
    }
    precondition {
      condition     = var.monitoring_interval == 0 || length("${local.monitoring_role_name}-role") <= 64
      error_message = "The monitoring role name \"${local.monitoring_role_name}-role\" is longer than the 64 characters IAM allows; shorten identifier."
    }
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-${var.application}-subnet-group"
  subnet_ids = var.internal_subnets

  tags = {
    Name        = "${var.environment}-${var.application}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-${var.application}-parameter-group"
  family = var.parameter_family

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name        = "${var.environment}-${var.application}-parameter-group"
    Environment = var.environment
  }
}
