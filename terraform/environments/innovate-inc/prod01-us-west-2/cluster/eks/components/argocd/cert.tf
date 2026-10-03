#ACM certificate for the Argo CD host, DNS-validated in the public zone, presented by the shared ALB.

module "argocd_certificate" {
  source = "../../../../../../../modules/aws-pub-cert/certificate-1.0-merged"

  environment     = var.environment
  application     = "argocd"
  route53_zone_id = local.public_zone_id
  domain_name     = local.argocd_host
}
