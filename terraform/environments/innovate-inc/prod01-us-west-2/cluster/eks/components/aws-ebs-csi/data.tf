data "aws_partition" "current" {}

data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

data "aws_eks_addon_version" "ebs_csi" {
  count = var.driver == "addon" ? 1 : 0

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = local.cluster_version
  most_recent        = true
}
