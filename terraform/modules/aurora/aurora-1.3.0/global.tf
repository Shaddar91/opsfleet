#Aurora global database <environment>-<application>-aurora-global, created with create_global_cluster; the cluster joins it.

resource "aws_rds_global_cluster" "main" {
  count                     = var.create_global_cluster ? 1 : 0
  global_cluster_identifier = local.global_cluster_identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = var.storage_encrypted
  deletion_protection       = var.deletion_protection

  tags = {
    Name        = local.global_cluster_identifier
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [engine_version]
  }
}
