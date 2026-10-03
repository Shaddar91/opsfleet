#KEDA operator role through iam/role, read-only CloudWatch, bound to keda/keda-operator by EKS Pod Identity.

module "keda_role" {
  source        = "../../iam/role"
  custom_policy = true

  name               = "${var.cluster_name}-keda"
  assume_role_policy = data.aws_iam_policy_document.keda_assume.json
  policy_file        = file("${path.module}/files/policies/keda-cloudwatch.json")
}

resource "aws_eks_pod_identity_association" "keda" {
  cluster_name    = var.cluster_name
  namespace       = local.namespace
  service_account = local.service_account
  role_arn        = module.keda_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.keda_role]
}
