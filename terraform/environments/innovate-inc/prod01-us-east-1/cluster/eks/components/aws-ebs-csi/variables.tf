variable "driver" {
  description = "How the driver is installed: addon, the EKS managed add-on; or helm, the labeled fallback (chart aws-ebs-csi-driver at chart_version) for when the add-on configuration schema rejects controller.region at deploy"
  type        = string

  validation {
    condition     = contains(["addon", "helm"], var.driver)
    error_message = "driver must be addon or helm."
  }
}

variable "addon_version" {
  description = "aws-ebs-csi-driver add-on version pin, vX.Y.Z-eksbuild.N; null takes the most recent version for the cluster's Kubernetes version. Pin from the addon_version output after the first apply"
  type        = string

  validation {
    condition     = var.addon_version == null || can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+-eksbuild\\.[0-9]+$", var.addon_version))
    error_message = "addon_version must be null or vX.Y.Z-eksbuild.N, e.g. v1.66.0-eksbuild.1."
  }
}

variable "chart_version" {
  description = "aws-ebs-csi-driver Helm chart version, used only when driver is helm"
  type        = string
}

variable "storage_class_name" {
  description = "Name of the gp3 StorageClass, the cluster's default class"
  type        = string
}

variable "filesystem_type" {
  description = "Filesystem the driver creates on new gp3 volumes, the csi.storage.k8s.io/fstype parameter"
  type        = string
}

variable "gp3_iops" {
  description = "Provisioned IOPS per gp3 volume"
  type        = number

  validation {
    condition     = var.gp3_iops >= 3000 && floor(var.gp3_iops) == var.gp3_iops
    error_message = "gp3_iops must be a whole number of at least 3000, the gp3 baseline."
  }
}

variable "gp3_throughput" {
  description = "Provisioned throughput per gp3 volume, in MiB/s"
  type        = number

  validation {
    condition     = var.gp3_throughput >= 125 && floor(var.gp3_throughput) == var.gp3_throughput
    error_message = "gp3_throughput must be a whole number of MiB/s, at least 125, the gp3 baseline."
  }
}
