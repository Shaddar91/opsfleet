#Database secret <environment>-<application>-database, written from this stack's values: the proxy's internal name as host, the reader name, port, database, master user and its password from the tier's secrets.auto.tfvars. The proxy authenticates with it and every backend pulls it by name through its SecretProviderClass.

module "database_secret" {
  source        = "../../../../modules/secrets-manager/sm-03"
  manage_values = true

  environment = var.environment
  application = "${var.application}-database"
  description = "Database settings of ${var.environment}-${var.application}-aurora-cluster, read by the proxy and the backends"
  secrets = {
    engine      = "postgres"
    host        = local.db_host
    reader_host = local.db_reader_host
    port        = tostring(module.aurora.port)
    dbname      = var.database_name
    username    = var.master_username
    password    = var.aurora_master_password
  }
}
