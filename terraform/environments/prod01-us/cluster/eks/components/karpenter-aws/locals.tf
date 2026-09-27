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
}
