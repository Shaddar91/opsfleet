module "keda" {
  source = "../../../../../../../modules/kubernetes/keda-1.0"

  cluster_name  = local.cluster_name
  chart_version = var.chart_version
}
