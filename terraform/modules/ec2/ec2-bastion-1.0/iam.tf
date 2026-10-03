resource "aws_iam_policy" "ec2_s3_ansible" {
  name   = "${var.environment}-${var.application}-policy"
  policy = data.aws_iam_policy_document.ec2_s3_ansible_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach_ec2_s3_ansible" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_ansible.arn
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
