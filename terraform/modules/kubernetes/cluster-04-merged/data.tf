data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended/image_id"
}

data "aws_iam_policy_document" "eks_kubectl_connection" {
  statement {
    actions   = ["eks:ListClusters"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["eks:AccessKubernetesApi", "eks:DescribeCluster"]
    effect    = "Allow"
    resources = [aws_eks_cluster.main.arn]
  }
}

data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    actions = ["ec2-instance-connect:SendSSHPublicKey"]
    effect  = "Allow"

    resources = ["*"]
  }
}

data "external" "thumbprint" {
  program = ["${path.module}/files/scripts/thumbprint.sh"]
}

data "aws_ebs_volumes" "eks_volumes" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-${var.application}-ebs"]
  }
}
