output "release_name" {
  description = "Helm release name of the Karpenter controller"
  value       = helm_release.karpenter.name
}

output "namespace" {
  description = "Namespace Karpenter runs in"
  value       = helm_release.karpenter.namespace
}

output "chart_version" {
  description = "Installed karpenter and karpenter-crd chart version"
  value       = helm_release.karpenter.version
}

output "status" {
  description = "Helm release status; deployed once the release is healthy"
  value       = helm_release.karpenter.status
}

output "node_class_name" {
  description = "EC2NodeClass every NodePool references"
  value       = { for pool, class in kubectl_manifest.ec2nodeclass : pool => class.name }
}

output "node_pools" {
  description = "NodePool names, x86 (default) and graviton (opt-in through the arch=arm64:NoSchedule taint)"
  value       = [for pool in kubectl_manifest.nodepool : pool.name]
}
