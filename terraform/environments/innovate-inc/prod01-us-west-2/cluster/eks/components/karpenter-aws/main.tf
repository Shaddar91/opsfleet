#EventBridge rules that forward health, Spot, rebalance, state-change and capacity-reservation events into the interruption queue (sqs.tf).

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
  arn       = module.interruption_queue.arn
}
