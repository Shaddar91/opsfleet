locals {
  release_name = "traefik"
  namespace    = "ingress"
  service_name = "traefik"
  service_port = "web"
  #must match the edge and internal-alb target groups: traffic to web, the /ping health check to traefik
  pod_ports = { web = 8000, traefik = 8080 }

  alb_pod_rules = {
    for pair in setproduct(keys(local.albs), keys(local.pod_ports)) : "${pair[0]}-${pair[1]}" => {
      alb       = pair[0]
      port_name = pair[1]
    }
  }

  target_group_bindings = {
    for alb, lb in local.albs : alb => templatefile("${path.module}/files/templates/targetgroupbinding-${alb}.yaml", {
      NAME             = "${local.release_name}-${alb}"
      NAMESPACE        = local.namespace
      TARGET_GROUP_ARN = lb.target_group_arn
      SERVICE_NAME     = local.service_name
      SERVICE_PORT     = local.service_port
    })
  }
}
