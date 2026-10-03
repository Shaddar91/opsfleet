#Read replicas <identifier>-ro, -ro1, ... in the primary's subnet group, with their own parameter group.

resource "aws_db_instance" "replica" {
  count                               = var.read_replica_count
  identifier                          = local.replica_identifiers[count.index]
  replicate_source_db                 = aws_db_instance.main.identifier
  instance_class                      = var.instance_class
  port                                = var.port
  parameter_group_name                = aws_db_parameter_group.replica[0].name
  vpc_security_group_ids              = local.vpc_security_group_ids
  availability_zone                   = var.replica_multi_az ? null : (count.index > 0 && var.replica_additional_availability_zone != null ? var.replica_additional_availability_zone : var.availability_zone)
  multi_az                            = var.replica_multi_az
  publicly_accessible                 = var.replica_publicly_accessible
  storage_encrypted                   = var.storage_encrypted
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backup_retention_period             = var.replica_backup_retention_period
  auto_minor_version_upgrade          = var.replica_auto_minor_version_upgrade
  performance_insights_enabled        = var.replica_performance_insights_enabled
  apply_immediately                   = var.apply_immediately
  skip_final_snapshot                 = true

  tags = {
    Name        = local.replica_identifiers[count.index]
    Environment = var.environment
  }

  lifecycle {
    precondition {
      condition     = !var.manage_master_user_password || can(regex("^(sqlserver|db2)-", var.engine))
      error_message = "RDS cannot create a read replica of a ${var.engine} instance whose master password Secrets Manager manages (RDS User Guide, Secrets Manager integration, Limitations). Set manage_master_user_password = false and pass password_wo, or set read_replica_count = 0."
    }
    precondition {
      condition     = var.backup_retention_period > 0
      error_message = "backup_retention_period must be above 0 while read replicas exist: AWS refuses 0 on a replica source."
    }
    precondition {
      condition     = !(var.replica_multi_az && var.replica_additional_availability_zone != null)
      error_message = "replica_additional_availability_zone must be null when replica_multi_az is true."
    }
    precondition {
      condition     = length(local.replica_identifiers[count.index]) <= 63
      error_message = "The replica identifier \"${local.replica_identifiers[count.index]}\" is longer than the 63 characters RDS allows."
    }
  }
}

resource "aws_db_parameter_group" "replica" {
  count  = var.read_replica_count > 0 ? 1 : 0
  name   = "${var.environment}-${var.application}-parameter-group-ro"
  family = var.parameter_family

  dynamic "parameter" {
    for_each = var.replica_db_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name        = "${var.environment}-${var.application}-parameter-group-ro"
    Environment = var.environment
  }
}
