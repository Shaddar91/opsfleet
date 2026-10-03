#external-dns role through iam/role, bound to external-dns/external-dns by EKS Pod Identity.

module "external_dns_role" {
  source        = "../../iam/role"
  custom_policy = true

  name               = "${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume.json
  policy_file = templatefile("${path.module}/files/policies/external-dns.json", {
    PARTITION      = data.aws_partition.current.partition
    HOSTED_ZONE_ID = var.zone_id
  })
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.cluster_name
  namespace       = local.namespace
  service_account = local.service_account
  role_arn        = module.external_dns_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.external_dns_role]
}
