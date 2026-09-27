locals {
  cluster_name   = coalesce(var.cluster_name, "${var.environment}-${var.application}-eks")
  node_role_name = element(split("/", var.node_role_arn), length(split("/", var.node_role_arn)) - 1)

  node_groups    = { for ng in var.node_groups : ng.name => ng }
  instance_types = toset(flatten([for ng in var.node_groups : ng.instance_types]))
  custom_amis    = { for name, ng in local.node_groups : name => ng.image_id if ng.image_id != null }

  ng_ami_type = { for name, ng in local.node_groups : name => ng.image_id == null ? coalesce(ng.ami_type, "AL2023_x86_64_STANDARD") : null }
  ng_arch = { for name, ng in local.node_groups : name => (
    ng.image_id == null ? (strcontains(local.ng_ami_type[name], "ARM_64") ? "arm64" : "x86_64") : data.aws_ami.ng[name].architecture
  ) }

  taint_effects = {
    NO_SCHEDULE        = "NoSchedule"
    NO_EXECUTE         = "NoExecute"
    PREFER_NO_SCHEDULE = "PreferNoSchedule"
  }
  kubelet_flags = { for name, ng in local.node_groups : name => concat(
    length(ng.labels) > 0 ? ["--node-labels=${join(",", [for key, value in ng.labels : "${key}=${value}"])}"] : [],
    length(ng.taints) > 0 ? ["--register-with-taints=${join(",", [for t in ng.taints : "${t.key}${t.value == null ? "" : "=${t.value}"}:${local.taint_effects[t.effect]}"])}"] : [],
  ) }

  addons_before_compute = { for name, addon in var.addons : name => addon if addon.before_compute }
  addons_after_compute  = { for name, addon in var.addons : name => addon if !addon.before_compute }
  addon_versions        = { for name, addon in var.addons : name => addon.version != null ? addon.version : data.aws_eks_addon_version.main[name].version }

  access_policy_associations = { for association in flatten([
    for entry_key, entry in var.access_entries : [
      for policy_key, policy in entry.policy_associations : merge(policy, { entry = entry_key, key = "${entry_key}/${policy_key}" })
    ]
  ]) : association.key => association }

  cluster_security_group_tags = merge(
    var.karpenter_discovery_tag ? { "karpenter.sh/discovery" = local.cluster_name } : {},
    var.cluster_security_group_tags,
  )
}
