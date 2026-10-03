#The two Opsfleet hosted zones, delegated from the parent zone: domain_name for public names, internal-<domain_name> for internal ones.

module "public_zone" {
  source            = "../../../modules/r53/hosted-zone-1.0"
  create_delegation = true
  mail_lockdown     = true

  name           = var.domain_name
  parent_zone_id = data.aws_route53_zone.parent.zone_id
  comment        = "Opsfleet public names"
  tags           = { Environment = var.environment }
}

module "internal_zone" {
  source            = "../../../modules/r53/hosted-zone-1.0"
  create_delegation = true
  mail_lockdown     = true

  name           = local.internal_domain_name
  parent_zone_id = data.aws_route53_zone.parent.zone_id
  comment        = "Opsfleet internal names"
  tags           = { Environment = var.environment }
}
