locals {
  argocd_host = "${var.argocd_subdomain}.${local.public_zone_domain_name}"
}
