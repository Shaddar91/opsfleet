#external-dns: Route 53 records for Ingress and Service hostnames under the public zone's domain_name.

module "external_dns" {
  source = "../../../../../../../modules/kubernetes/external-dns-1.0"

  cluster_name  = local.cluster_name
  chart_version = var.chart_version
  zone_id       = local.public_zone_id
  domain_name   = local.public_zone_domain_name
  region        = var.region
}
