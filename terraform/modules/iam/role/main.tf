resource "aws_iam_role" "main" {
  name                  = var.name == null ? "${var.environment}-${var.application}-role" : "${var.name}-role"
  force_detach_policies = true
  assume_role_policy = var.assume_role_policy == null ? templatefile(
    "${path.module}/files/assume_role.json",
    { service = var.aws_service }
  ) : var.assume_role_policy
  tags = {
    Name = var.name == null ? "${var.environment}-${var.application}-role" : "${var.name}-role"
  }
  max_session_duration = var.max_session_duration
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_iam_role_policy_attachment" "main" {
  count      = var.custom_policy ? length(var.policy_list) + 1 : length(var.policy_list)
  role       = aws_iam_role.main.name
  policy_arn = count.index == length(var.policy_list) ? aws_iam_policy.main[0].arn : var.policy_list[count.index]
}
resource "aws_iam_policy" "main" {
  count  = var.custom_policy ? 1 : 0
  name   = var.name == null ? "${var.environment}-${var.application}-policy" : "${var.name}-policy"
  policy = var.policy_file
}
resource "aws_iam_instance_profile" "main" {
  count = var.instance_profile ? 1 : 0
  name  = "${var.environment}-${var.application}-instance-profile"
  role  = aws_iam_role.main.name
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.name == null ? "${var.environment}-${var.application}-profile" : "${var.name}-profile"
  }
}