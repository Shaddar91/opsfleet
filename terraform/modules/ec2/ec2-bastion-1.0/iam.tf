resource "aws_iam_policy" "ec2_s3_ansible" {
  name   = "${var.environment}-${var.application}-policy"
  policy = data.aws_iam_policy_document.ec2_s3_ansible_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach_ec2_s3_ansible" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_ansible.arn
}

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

resource "aws_iam_role" "ec2_role" {
  name               = var.name == null ? "${var.environment}-${var.application}-role" : var.iam_role_name
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags = {
    Name = var.name == null ? "${var.environment}-${var.application}-profile" : "${var.name}-profile"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.name == null ? "${var.environment}-${var.application}-profile" : var.iam_profile_name
  role = aws_iam_role.ec2_role.name
  tags = {
    Name = var.name == null ? "${var.environment}-${var.application}-profile" : "${var.name}-profile"
  }
}
