data "aws_ec2_instance_type" "ng" {
  for_each      = local.instance_types
  instance_type = each.key
}

data "aws_ami" "ng" {
  for_each           = local.custom_amis
  include_deprecated = true

  filter {
    name   = "image-id"
    values = [each.value]
  }
}

#Keyed on var.cluster_version, not the cluster attribute, so a pending cluster change never defers the read to apply.
data "aws_eks_addon_version" "main" {
  for_each           = { for name, addon in var.addons : name => addon if addon.version == null }
  addon_name         = each.key
  kubernetes_version = var.cluster_version
  most_recent        = each.value.most_recent
}
