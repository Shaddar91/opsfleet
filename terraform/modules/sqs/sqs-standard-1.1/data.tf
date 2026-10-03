data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowQueueAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = concat(
        ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
        var.allowed_principal_arns
      )
    }

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]

    resources = [aws_sqs_queue.main.arn]
  }

  dynamic "statement" {
    for_each = length(var.allowed_service_principals) > 0 ? [1] : []
    content {
      sid    = "AllowServiceSendMessage"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = var.allowed_service_principals
      }

      actions   = ["sqs:SendMessage"]
      resources = [aws_sqs_queue.main.arn]
    }
  }

  dynamic "statement" {
    for_each = var.enforce_tls ? [1] : []
    content {
      sid    = "DenyInsecureTransport"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions   = ["sqs:*"]
      resources = [aws_sqs_queue.main.arn]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }
}
