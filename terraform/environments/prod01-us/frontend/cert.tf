#Viewer certificate for web_fqdn only, issued in us-east-1 and DNS-validated in the system public zone.

module "cert" {
  source = "../../../modules/aws-pub-cert/certificate-1.0-merged"

  environment     = var.environment
  application     = var.application
  region          = "us-east-1"
  domain_name     = local.web_fqdn
  route53_zone_id = local.public_zone_id
}
