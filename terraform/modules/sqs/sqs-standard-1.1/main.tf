//Standard SQS queue with its access policy and an optional encrypted dead-letter queue.

resource "aws_sqs_queue" "main" {
  name                       = "${var.environment}-${var.application}-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled
  redrive_policy = var.create_dlq ? templatefile("${path.module}/files/policies/redrive.json", {
    DLQ_ARN           = aws_sqs_queue.dlq[0].arn
    MAX_RECEIVE_COUNT = var.max_receive_count
  }) : null
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.application}"
  })
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                    = "${var.environment}-${var.application}-dlq"
  sqs_managed_sse_enabled = true
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.application}-dlq"
  })
}

resource "aws_sqs_queue_policy" "main_policy" {
  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.main.json
}
