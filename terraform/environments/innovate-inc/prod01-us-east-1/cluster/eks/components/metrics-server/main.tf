#metrics-server: the metrics.k8s.io API behind HPAs and kubectl top, on the system node group.

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.chart_version
  namespace        = "kube-system"
  create_namespace = false
  values           = [file("${path.module}/files/values/metrics-server.yaml")]
}
