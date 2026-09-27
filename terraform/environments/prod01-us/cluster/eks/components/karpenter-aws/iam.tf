#Karpenter controller role through iam/role with the six upstream v1.14.1 controller policies, bound to kube-system/karpenter by EKS Pod Identity.

data "aws_iam_policy_document" "karpenter_controller_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

locals {
  controller_policy_documents = {
    for name in local.controller_policies : name => templatefile("${path.module}/files/policies/karpenter-controller-${name}.json", {
      partition              = data.aws_partition.current.partition
      region                 = var.region
      account_id             = data.aws_caller_identity.current.account_id
      cluster_name           = local.cluster_name
      node_role_arn          = local.karpenter_node_role_arn
      interruption_queue_arn = aws_sqs_queue.karpenter_interruption.arn
    })
  }
}

#six managed policies, not one: the merged controller policy exceeds the 6,144-character managed-policy cap
resource "aws_iam_policy" "karpenter_controller" {
  for_each = local.controller_policy_documents

  name   = "${local.cluster_name}-karpenter-${each.key}"
  policy = each.value

  tags = {
    Name        = "${local.cluster_name}-karpenter-${each.key}"
    Environment = var.environment
  }
}

module "karpenter_controller_role" {
  source = "../../../../../../modules/iam/role"

  name               = "${local.cluster_name}-karpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume.json
  policy_list        = [for policy in aws_iam_policy.karpenter_controller : policy.arn]
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = local.cluster_name
  namespace       = local.namespace
  service_account = local.service_account
  role_arn        = module.karpenter_controller_role.role_arn

  #role_arn carries no edge to the policy attachments: attach before, detach after the association
  depends_on = [module.karpenter_controller_role]
}

#iam/role cannot create a service-linked role; without this one Spot launches fail with AuthFailure.ServiceLinkedRoleCreationNotPermitted
resource "aws_iam_service_linked_role" "spot" {
  count = var.create_spot_service_linked_role ? 1 : 0

  aws_service_name = "spot.amazonaws.com"
}
