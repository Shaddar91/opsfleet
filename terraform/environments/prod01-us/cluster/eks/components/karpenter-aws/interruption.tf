#Interruption queue: EventBridge forwards health, Spot, rebalance, state-change and capacity-reservation events so Karpenter drains nodes ahead of them.

resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${local.cluster_name}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = {
    Name        = "${local.cluster_name}-karpenter"
    Environment = var.environment
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy = templatefile("${path.module}/files/policies/karpenter-interruption-queue.json", {
    interruption_queue_arn = aws_sqs_queue.karpenter_interruption.arn
  })
}

locals {
  interruption_event_patterns = {
    for key in keys(local.interruption_rules) : key => file("${path.module}/files/event-patterns/${key}.json")
  }
}

resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  for_each = local.interruption_event_patterns

  name          = "${local.cluster_name}-karpenter-${each.key}"
  description   = "Karpenter interruption queue: ${local.interruption_rules[each.key]}"
  event_pattern = each.value

  tags = {
    Name        = "${local.cluster_name}-karpenter-${each.key}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "karpenter_interruption" {
  for_each = aws_cloudwatch_event_rule.karpenter_interruption

  rule      = each.value.name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}
