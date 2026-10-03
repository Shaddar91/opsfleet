#innovate-inc Global Accelerator: static anycast IPs on TCP 80 and 443. It exists before any region; each region's edge stack attaches its ALB as an endpoint group.

module "global_accelerator" {
  source                      = "../../../../modules/global-accelerator/global-accelerator-1.1"
  enabled                     = var.enabled
  create_route53_health_check = var.create_route53_health_check

  environment     = var.environment
  application     = var.application
  ip_address_type = "IPV4"

  listeners = {
    web = {
      protocol = "TCP"
      port_ranges = [
        { from_port = 80, to_port = 80 },
        { from_port = 443, to_port = 443 },
      ]
    }
  }
}
