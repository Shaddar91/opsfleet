#of-load app service on service-0.4: edge ALB target group, host rule, certificate, record, SG rule and the Argo CD Application.

module "service" {
  source                      = "../../../../../modules/kubernetes/services/service-0.4"
  create_argocd_application   = true
  create_target_group_binding = false
  custom_target_group_binding = false
  create_certificate          = true
  create_security_group_rule  = false

  environment           = var.environment
  application           = var.application
  fqdn                  = local.fqdn
  zone_id               = local.public_zone_id
  listener_arn          = local.edge_listener_https_arn
  priority              = var.priority
  alb_security_group_id = local.edge_alb_security_group_id
  pod_security_group_id = local.cluster_security_group_id
  vpc_id                = local.vpc_id
  alias_target_dns_name = local.accelerator_dns_name
  alias_target_zone_id  = local.accelerator_hosted_zone_id
  container_port        = var.container_port
  health_check_path     = var.health_check_path
  argo_application_path = local.argo_application
  argocd_namespace      = var.argocd_namespace
  argocd_project        = var.argocd_project
  repo_url              = "https://github.com/${var.github_owner}/${var.git_repository}.git"
  target_revision       = var.git_branch
  chart_path            = var.git_path
  namespace             = var.namespace
  architecture          = var.architecture
  image_repository      = local.ecr_repository_url
}
