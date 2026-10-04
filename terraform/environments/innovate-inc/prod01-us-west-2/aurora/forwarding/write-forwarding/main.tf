#prod01-usw2 global write forwarding on the Aurora standby, in its own state: the region rollout applies it after aurora and destroys it first, so forwarding is off before the cluster goes.
module "write_forwarding" {
  source = "../../../../../../modules/aurora/write-forwarding-1.0"
  count  = local.write_forwarding ? 1 : 0

  region             = var.region
  cluster_identifier = local.cluster_identifier
}
