
resource "aws_eks_node_group" "main" {
  for_each        = { for ng in var.node_groups : ng.name => ng }
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value.name
  node_role_arn   = module.ec2_role.role_arn

  capacity_type   = each.value.capacity_type
  subnet_ids      = each.value.subnets
  instance_types  = each.value.instance_types

  scaling_config {
    desired_size = each.value.scaling.desired
    max_size     = each.value.scaling.max
    min_size     = each.value.scaling.min
  }

  ami_type   = try(each.value.ami_type, null)
  version    = try(each.value.node_version, null)
  # image_id   = try(each.value.image_id, null)
  labels     = try(each.value.labels, null)
  tags       = merge({
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" = "owned"
    "kubernetes.io/cluster/${aws_eks_cluster.main.name}"     = "owned"

    "Environment" = var.environment
    "Application" = var.application
  }, try(each.value.tags, {}))

  launch_template {
    id      = aws_launch_template.main[each.key].id
    version = aws_launch_template.main[each.key].latest_version
  }

  timeouts {
    create = var.node_group_timeouts.create
    update = var.node_group_timeouts.update
    delete = var.node_group_timeouts.delete
  }

  depends_on = [aws_launch_template.main]
}

resource "aws_launch_template" "main" {
  for_each                = { for ng in var.node_groups : ng.name => ng }
  name                    = "${var.environment}-${var.application}-${each.key}-lt"
  update_default_version  = true
  user_data               = base64encode(templatefile(var.user_data, merge(var.user_data_vars, {
    NODE_GROUP_NAME = each.key
    CAPACITY_TYPE   = each.value.capacity_type
    ENVIRONMENT     = var.environment
    APPLICATION     = var.application
  })))

  block_device_mappings {
    device_name = try(each.value.ebs.device_name, var.device_name)
    ebs {
      volume_size = try(each.value.ebs.size, var.ebs.size)
      iops        = try(each.value.ebs.iops, var.ebs.iops)
      throughput  = try(each.value.ebs.throughput, var.ebs.throughput)
      volume_type = try(each.value.ebs.type, var.ebs.type)
    }
  }

  image_id = try(each.value.image_id, var.image_id)

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
    try(each.value.extra_security_group_ids, var.extra_security_group_ids)
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
