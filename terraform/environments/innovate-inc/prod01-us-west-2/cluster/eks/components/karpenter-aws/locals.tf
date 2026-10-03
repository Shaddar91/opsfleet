locals {
  namespace       = "kube-system"
  service_account = "karpenter"

  controller_policies = toset(["node-lifecycle", "iam-integration", "eks-integration", "interruption", "resource-discovery", "zonal-shift"])

  #keys stay within 9 characters so <cluster_name>-karpenter-<key> fits EventBridge's 64 for every cluster_name the eks stack accepts
  interruption_rules = {
    health    = "AWS Health scheduled-change events"
    spot      = "EC2 Spot interruption warnings"
    rebalance = "EC2 rebalance recommendations"
    state     = "EC2 instance state-change notifications"
    capacity  = "EC2 capacity-reservation interruption warnings"
  }

  controller_policy_documents = {
    for name in local.controller_policies : name => templatefile("${path.module}/files/policies/karpenter-controller-${name}.json", {
      PARTITION              = data.aws_partition.current.partition
      REGION                 = var.region
      ACCOUNT_ID             = data.aws_caller_identity.current.account_id
      CLUSTER_NAME           = local.cluster_name
      NODE_ROLE_ARN          = local.karpenter_node_role_arn
      INTERRUPTION_QUEUE_ARN = module.interruption_queue.arn
    })
  }

  interruption_event_patterns = {
    for key in keys(local.interruption_rules) : key => file("${path.module}/files/event-patterns/${key}.json")
  }

  interruption_queue = {
    retention_seconds = 300
    principals        = ["events.amazonaws.com", "sqs.amazonaws.com"]
  }
}
