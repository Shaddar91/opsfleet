resource "aws_iam_group" "main" {
  name = var.group
  path = var.path
}
resource "aws_iam_group_policy_attachment" "main" {
  count      = var.custom_policy ? length(var.policy_list) + 1 : length(var.policy_list)
  group      = aws_iam_group.main.name
  policy_arn = count.index == length(var.policy_list) ? aws_iam_policy.main[0].arn : var.policy_list[count.index]
}
resource "aws_iam_policy" "main" {
  count  = var.custom_policy ? 1 : 0
  name   = "${var.group}-group-policy"
  policy = var.policy_file
}