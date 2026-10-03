output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI controller role, bound to kube-system/ebs-csi-controller-sa by Pod Identity"
  value       = module.ebs_csi_role.role_arn
}

output "addon_version" {
  description = "Installed aws-ebs-csi-driver add-on version, the value to pin in addon_version; null when driver is helm"
  value       = one(aws_eks_addon.ebs_csi[*].addon_version)
}

output "default_storage_class" {
  description = "Name of the default StorageClass this stack creates"
  value       = kubectl_manifest.gp3_storage_class.name
}
