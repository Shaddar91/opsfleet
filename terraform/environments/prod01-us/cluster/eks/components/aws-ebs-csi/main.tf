#aws-ebs-csi-driver as the EKS managed add-on, or as the labeled Helm fallback when driver = "helm".

data "aws_eks_addon_version" "ebs_csi" {
  count = var.driver == "addon" ? 1 : 0

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi" {
  count = var.driver == "addon" ? 1 : 0

  cluster_name  = local.cluster_name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = coalesce(var.addon_version, data.aws_eks_addon_version.ebs_csi[0].version)
  configuration_values = templatefile("${path.module}/files/values/aws-ebs-csi.json.tpl", {
    region = var.region
  })
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_pod_identity_association.ebs_csi]
}

resource "helm_release" "ebs_csi" {
  count = var.driver == "helm" ? 1 : 0

  name             = "aws-ebs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = false
  values = [templatefile("${path.module}/files/values/aws-ebs-csi-helm.yaml.tpl", {
    region          = var.region
    service_account = local.service_account
  })]

  depends_on = [aws_eks_pod_identity_association.ebs_csi]
}
