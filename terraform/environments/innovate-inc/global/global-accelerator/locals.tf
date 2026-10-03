locals {
  app_fqdn = "${var.app_subdomain}.${local.public_zone_domain_name}"
}
