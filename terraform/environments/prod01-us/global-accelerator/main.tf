#prod01-us Global Accelerator: static anycast IPs on TCP 80 and 443 in front of the edge ALB.

module "global_accelerator" {
  source = "../../../modules/global-accelerator/global-accelerator-1.0-merged"

  environment     = var.environment
  application     = var.application
  enabled         = var.enabled
  ip_address_type = "IPV4"

  create_route53_health_check = var.create_route53_health_check

  listeners = {
    web = {
      protocol = "TCP"
      port_ranges = [
        { from_port = 80, to_port = 80 },
        { from_port = 443, to_port = 443 },
      ]
      endpoint_group = {
        region = var.region
        endpoints = [
          {
            endpoint_id                    = local.edge_alb_arn
            client_ip_preservation_enabled = true
          },
        ]
      }
    }
  }
}
