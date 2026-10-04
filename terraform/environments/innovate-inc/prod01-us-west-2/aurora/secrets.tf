#Database secret <environment>-<application>-database for this region, written from this stack's values: as host the reader name while write forwarding is on, else the proxy's internal name, the reader name, port, the global database's name and master user, the password from the tier's secrets.auto.tfvars. The proxy authenticates with it and every backend here pulls it by name.

module "database_secret" {
  source        = "../../../../modules/secrets-manager/sm-03"
  manage_values = true

  environment = var.environment
  application = "${var.application}-database"
  description = "Database settings of ${var.environment}-${var.application}-aurora-cluster, read by the proxy and the backends"
  secrets = {
    engine      = "postgres"
    host        = local.backend_db_host
    reader_host = local.db_reader_host
    port        = tostring(module.aurora.port)
    dbname      = local.database_name
    username    = local.master_username
    password    = var.aurora_master_password
  }
}
