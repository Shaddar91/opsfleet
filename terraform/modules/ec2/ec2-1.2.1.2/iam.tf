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
    sid    = "s3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.ansible_bucket_name}/",
      "arn:aws:s3:::${var.ansible_bucket_name}/*"
    ]
  }

  statement {
    sid    = "ec2"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "cloudwatch"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = var.name != null ? "${var.name}-role" : "${var.environment}-${var.application}-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json

  tags = {
    Name        = var.name != null ? "${var.name}-role" : "${var.environment}-${var.application}-role"
    Environment = var.environment
    Application = var.application
  }

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.name != null ? "${var.name}-profile" : "${var.environment}-${var.application}-profile"
  role = aws_iam_role.ec2_role.name


  tags = {
    Name        = var.name != null ? "${var.name}-profile" : "${var.environment}-${var.application}-profile"
    Environment = var.environment
    Application = var.application
  }
}
