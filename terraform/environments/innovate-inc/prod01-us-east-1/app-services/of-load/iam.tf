#Role the of-load pods assume by EKS Pod Identity: read the app secret, nothing else.

module "secrets_role" {
  source        = "../../../../../modules/iam/role"
  custom_policy = true

  name               = "${local.cluster_name}-${var.application}-secrets"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  policy_file = templatefile("${path.module}/files/policies/secrets-read.json", {
    SECRET_ARNS = [module.app_secret.arn]
  })
}

resource "aws_eks_pod_identity_association" "secrets" {
  cluster_name    = local.cluster_name
  namespace       = var.namespace
  service_account = module.service.application_name

  role_arn = module.secrets_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.secrets_role]
}
