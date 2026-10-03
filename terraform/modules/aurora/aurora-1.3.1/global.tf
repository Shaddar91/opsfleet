#Aurora global database <environment>-<application>-aurora-global, created from the cluster with create_global_cluster, on the first apply or on a later one once the instances run a class that supports global databases.

resource "aws_rds_global_cluster" "main" {
  count                        = var.create_global_cluster ? 1 : 0
  global_cluster_identifier    = local.global_cluster_identifier
  source_db_cluster_identifier = aws_rds_cluster.main.arn
  force_destroy                = true
  deletion_protection          = var.deletion_protection

  tags = {
    Name        = local.global_cluster_identifier
    Environment = var.environment
  }

  depends_on = [aws_rds_cluster_instance.main]

  lifecycle {
    ignore_changes = [engine_version]

    precondition {
      condition     = !startswith(local.instance_class, "db.t")
      error_message = "A global database refuses burstable classes (db.t3, db.t4g): set instance_class to db.r6g.large or larger before create_global_cluster = true."
    }
  }
}
