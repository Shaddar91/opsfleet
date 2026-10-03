locals {
  internal_ingress_hosts = coalescelist(var.internal_ingress_hosts, ["*.internal.${local.public_zone_domain_name}"])
}
