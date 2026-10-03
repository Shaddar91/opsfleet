data "aws_iam_policy_document" "ec2_s3_ansible_iam_policy" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.ansible_bucket_name}/ansible/*"
    ]
  }

  statement {
    sid    = "EC2InstanceConnect"
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey",
      "ec2:DescribeInstances"
    ]

    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
