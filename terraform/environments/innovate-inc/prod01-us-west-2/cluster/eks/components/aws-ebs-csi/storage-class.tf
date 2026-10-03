#gp3 default StorageClass; force_new replaces it on any change, because StorageClass parameters are immutable.

resource "kubectl_manifest" "gp3_storage_class" {
  yaml_body = templatefile("${path.module}/files/templates/gp3-storage-class.yaml", {
    NAME       = var.storage_class_name
    FSTYPE     = var.filesystem_type
    IOPS       = var.gp3_iops
    THROUGHPUT = var.gp3_throughput
  })
  force_new = true

  depends_on = [aws_eks_addon.ebs_csi, helm_release.ebs_csi]
}
