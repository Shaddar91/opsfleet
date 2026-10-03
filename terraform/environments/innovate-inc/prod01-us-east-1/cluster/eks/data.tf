data "aws_partition" "current" {}

data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_group_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "karpenter_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

#Resolves an assumed-role session to its role ARN; an IAM user ARN passes through unchanged.
data "aws_iam_session_context" "runner" {
  arn = data.aws_caller_identity.current.arn
}

data "http" "runner_ip" {
  url = "https://checkip.amazonaws.com"
}
