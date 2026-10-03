#external-dns: Route 53 records for Ingress and Service hostnames under domain_name, written only into zone_id.

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = true
  values = [templatefile("${path.module}/files/values/external-dns.yaml", {
    REGION          = var.region
    ZONE_ID         = var.zone_id
    DOMAIN_NAME     = var.domain_name
    CLUSTER_NAME    = var.cluster_name
    SERVICE_ACCOUNT = local.service_account
  })]

  depends_on = [aws_eks_pod_identity_association.external_dns]
}

#on destroy this waits first, so external-dns gets one more sync to delete the records of Ingresses removed just before it
resource "time_sleep" "record_cleanup" {
  destroy_duration = "90s"

  depends_on = [helm_release.external_dns]
}
