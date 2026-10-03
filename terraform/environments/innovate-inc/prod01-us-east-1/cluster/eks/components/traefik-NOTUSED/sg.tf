#ALB to Traefik pods: the edge and internal ALB security groups into the EKS cluster security group, the only one Karpenter nodes carry.

resource "aws_vpc_security_group_ingress_rule" "alb_to_traefik" {
  for_each = local.alb_pod_rules

  security_group_id            = local.cluster_security_group_id
  referenced_security_group_id = local.albs[each.value.alb].security_group_id
  description                  = "${each.value.alb} ALB to Traefik ${each.value.port_name} port"
  ip_protocol                  = "tcp"
  from_port                    = local.pod_ports[each.value.port_name]
  to_port                      = local.pod_ports[each.value.port_name]

  tags = {
    Name        = "${var.environment}-traefik-${each.key}-in"
    Environment = var.environment
  }
}
