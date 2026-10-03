//edge ALB security group -> pod security group on container_port

resource "aws_vpc_security_group_ingress_rule" "alb_to_pods" {
  count = var.create_security_group_rule ? 1 : 0

  security_group_id            = var.pod_security_group_id
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
}
