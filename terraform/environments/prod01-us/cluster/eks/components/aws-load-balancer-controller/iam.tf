#AWS Load Balancer Controller role through iam/role, bound to kube-system/aws-load-balancer-controller by EKS Pod Identity.

data "aws_iam_policy_document" "lbc_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

module "lbc_role" {
  source = "../../../../../../modules/iam/role"

  name               = "${local.cluster_name}-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume.json
  custom_policy      = true
  policy_file        = file("${path.module}/files/policies/aws-load-balancer-controller.json")
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = local.cluster_name
  namespace       = local.namespace
  service_account = local.service_account
  role_arn        = module.lbc_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.lbc_role]
}
