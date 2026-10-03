module "config" {
  source        = "../../../../../modules/secrets-manager/sm-03"
  manage_values = true

  environment = var.environment
  application = "failover-regional"
  description = "Targets of the regional failover function: the global database, each region's cluster and accelerator endpoint group"
  secrets     = local.config
}
