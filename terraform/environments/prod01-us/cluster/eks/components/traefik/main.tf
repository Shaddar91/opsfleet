#Traefik: the in-cluster router behind the edge and internal ALBs, a ClusterIP Service whose pods the TargetGroupBindings register.

resource "helm_release" "traefik" {
  name             = local.release_name
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = false
  skip_crds        = true
  values = [templatefile("${path.module}/files/values/traefik.yaml.tpl", {
    service_name = local.service_name
    web_port     = local.pod_ports.web
    traefik_port = local.pod_ports.traefik
    vpc_cidr     = local.vpc_cidr
  })]

  depends_on = [kubectl_manifest.crds]
}
