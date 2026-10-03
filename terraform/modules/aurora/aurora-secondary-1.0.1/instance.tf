#Cluster instances <environment>-<application>-aurora-instance-1, -2, ...

resource "aws_rds_cluster_instance" "main" {
  count                = var.instance_count
  identifier           = local.instance_identifiers[count.index]
  cluster_identifier   = aws_rds_cluster.main.id
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  instance_class       = local.instance_class
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name        = local.instance_identifiers[count.index]
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [engine_version]

    precondition {
      condition     = local.instance_class != null
      error_message = "instance_class is required for a provisioned cluster: set it, or set serverlessv2_scaling for db.serverless instances."
    }
    precondition {
      condition     = local.instance_class != "db.serverless" || var.serverlessv2_scaling != null
      error_message = "db.serverless instances need serverlessv2_scaling: AWS refuses a Serverless v2 instance in a cluster without a capacity range."
    }
    precondition {
      condition     = length(local.instance_identifiers[count.index]) <= 63
      error_message = "The instance identifier \"${local.instance_identifiers[count.index]}\" is longer than the 63 characters RDS allows."
    }
  }
}
