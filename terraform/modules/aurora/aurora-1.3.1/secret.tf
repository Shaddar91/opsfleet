#Master user secret <environment>-<application>-aurora-master with a generated password, created with create_master_user_secret.

ephemeral "aws_secretsmanager_random_password" "master" {
  count              = var.create_master_user_secret ? 1 : 0
  password_length    = 32
  exclude_characters = "/\"@ \\"
}

resource "aws_secretsmanager_secret" "master" {
  count       = var.create_master_user_secret ? 1 : 0
  name        = local.master_user_secret_name
  description = "Master user of ${local.cluster_identifier}"

  dynamic "replica" {
    for_each = var.master_user_secret_replica_regions

    content {
      region = replica.value
    }
  }

  tags = {
    Name        = local.master_user_secret_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "master" {
  count     = var.create_master_user_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.master[0].id
  secret_string_wo = templatefile("${path.module}/files/templates/master-user.json", {
    USERNAME = var.master_username
    PASSWORD = ephemeral.aws_secretsmanager_random_password.master[0].random_password
  })
  secret_string_wo_version = var.master_password_wo_version

  #After the cluster: a failed cluster create must not leave a password the cluster never took.
  depends_on = [aws_rds_cluster.main]
}
