module "cluster_role" {
  source      = "../../iam/role/"
  environment = var.environment
  application = var.application
  aws_service = "eks.amazonaws.com"
  policy_list = concat(var.default_cluster_role_policy_list, var.extra_cluster_policy_list)
}

#IAM node role
module "ec2_role" {
  source        = "../../iam/role/"
  environment   = var.environment
  application   = "${var.application}-ec2"
  aws_service   = "ec2.amazonaws.com"
  custom_policy = true
  policy_file = templatefile(
    var.node_policy_file_location,
    var.node_policy_template_vars
  )
  policy_list = concat(var.default_ec2_role_policy_list, var.extra_ec2_policy_list)
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
resource "aws_iam_policy" "eks_kubectl_connection" {
  policy = data.aws_iam_policy_document.eks_kubectl_connection.json
  name   = "${var.environment}-${var.application}-eks-kubectl-connection"
}

data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    actions = ["ec2-instance-connect:SendSSHPublicKey"]
    effect  = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_instance_connect_policy" {
  name   = "${var.environment}-${var.application}-ec2-instance-connect-policy"
  policy = data.aws_iam_policy_document.ec2_instance_connect.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_connect_attachment" {
  role       = module.ec2_role.role_name
  policy_arn = aws_iam_policy.ec2_instance_connect_policy.arn
}
