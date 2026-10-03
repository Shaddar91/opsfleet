resource "aws_eks_node_group" "main" {
  for_each        = local.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn

  capacity_type   = each.value.capacity_type
  subnet_ids      = each.value.subnets
  instance_types  = each.value.instance_types
  ami_type        = local.ng_ami_type[each.key]
  version         = each.value.node_version
  release_version = each.value.release_version
  labels          = each.value.labels

  scaling_config {
    desired_size = each.value.scaling.desired
    max_size     = each.value.scaling.max
    min_size     = each.value.scaling.min
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = each.value.update_config == null ? [] : [each.value.update_config]
    content {
      max_unavailable            = update_config.value.max_unavailable
      max_unavailable_percentage = update_config.value.max_unavailable_percentage
    }
  }

  tags = merge({
    "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "owned"
    "Environment"                                        = var.environment
    "Application"                                        = var.application
  }, each.value.tags)

  launch_template {
    id      = aws_launch_template.main[each.key].id
    version = aws_launch_template.main[each.key].latest_version
  }

  timeouts {
    create = var.node_group_timeouts.create
    update = var.node_group_timeouts.update
    delete = var.node_group_timeouts.delete
  }

  lifecycle {
    precondition {
      condition     = alltrue([for type in each.value.instance_types : contains(data.aws_ec2_instance_type.ng[type].supported_architectures, local.ng_arch[each.key])])
      error_message = "Node group ${each.key} runs ${local.ng_arch[each.key]}, which ${join(", ", [for type in each.value.instance_types : type if !contains(data.aws_ec2_instance_type.ng[type].supported_architectures, local.ng_arch[each.key])])} cannot run. Graviton types need ami_type AL2023_ARM_64_*, the others AL2023_x86_64_*."
    }
  }

  depends_on = [aws_launch_template.main, aws_eks_addon.before_compute]
}

resource "aws_launch_template" "main" {
  for_each               = local.node_groups
  name                   = "${var.environment}-${var.application}-${each.key}-lt"
  update_default_version = var.update_default_version
  image_id               = each.value.image_id
  user_data = base64encode(templatefile(coalesce(var.user_data, "${path.module}/files/user_data.mime"), merge(var.user_data_vars, {
    NODE_GROUP_NAME       = each.key
    CAPACITY_TYPE         = each.value.capacity_type
    ENVIRONMENT           = var.environment
    APPLICATION           = var.application
    ARCH                  = local.ng_arch[each.key]
    AMI_TYPE              = coalesce(local.ng_ami_type[each.key], "CUSTOM")
    CUSTOM_AMI            = each.value.image_id != null
    CLUSTER_NAME          = aws_eks_cluster.main.name
    API_SERVER_ENDPOINT   = aws_eks_cluster.main.endpoint
    CERTIFICATE_AUTHORITY = aws_eks_cluster.main.certificate_authority[0].data
    SERVICE_CIDR          = aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr
    KUBELET_FLAGS         = local.kubelet_flags[each.key]
  })))

  block_device_mappings {
    device_name = coalesce(try(each.value.ebs.device_name, null), var.device_name)
    ebs {
      volume_size = try(each.value.ebs.size, var.ebs.size)
      iops        = try(each.value.ebs.iops, var.ebs.iops)
      throughput  = try(each.value.ebs.throughput, var.ebs.throughput)
      volume_type = try(each.value.ebs.type, var.ebs.type)
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.capacity_reservation_preference
  }
  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
    http_protocol_ipv6          = var.http_protocol_ipv6
    instance_metadata_tags      = var.instance_metadata_tags
  }
  vpc_security_group_ids = concat(
    [module.ec2_sg.sg.id, aws_eks_cluster.main.vpc_config[0].cluster_security_group_id],
    each.value.extra_security_group_ids != null ? each.value.extra_security_group_ids : var.extra_security_group_ids
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "${var.environment}-${var.application}-${each.key}-eks-node"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "Name" = "${var.environment}-${var.application}-${each.key}-ebs"
    }
  }
}
