#EBS CSI controller role through iam/role, bound to kube-system/ebs-csi-controller-sa by EKS Pod Identity.

module "ebs_csi_role" {
  source = "../../../../../../../modules/iam/role"

  name               = "${local.cluster_name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
  policy_list        = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = local.cluster_name
  namespace       = local.namespace
  service_account = local.service_account
  role_arn        = module.ebs_csi_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.ebs_csi_role]
}
