#gp3 default StorageClass; force_new replaces it on any change, because StorageClass parameters are immutable.

resource "kubectl_manifest" "gp3_storage_class" {
  yaml_body = templatefile("${path.module}/files/templates/gp3-storage-class.yaml.tpl", {
    name       = var.storage_class_name
    fstype     = var.filesystem_type
    iops       = var.gp3_iops
    throughput = var.gp3_throughput
  })
  force_new = true

  depends_on = [aws_eks_addon.ebs_csi, helm_release.ebs_csi]
}
