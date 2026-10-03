#AWS Load Balancer Controller: registers pod IPs into the Terraform-owned ALB target groups through TargetGroupBinding.

resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = var.chart_version
  namespace        = local.namespace
  create_namespace = false
  skip_crds        = true
  values = [templatefile("${path.module}/files/values/aws-load-balancer-controller.yaml", {
    CLUSTER_NAME    = local.cluster_name
    REGION          = var.region
    VPC_ID          = local.vpc_id
    SERVICE_ACCOUNT = local.service_account
  })]

  depends_on = [kubectl_manifest.crds, aws_eks_pod_identity_association.lbc]
}
