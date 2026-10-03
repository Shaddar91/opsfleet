locals {
  chart_dir        = "${path.module}/helm"
  argo_application = "${path.module}/argo/application.yaml"
  fqdn             = "${var.subdomain}.${trimsuffix(data.aws_route53_zone.service.name, ".")}"
}
