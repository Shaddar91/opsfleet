#The frontend's Lambda@Edge, as every other frontend ships it: on origin-request the User-Agent becomes the origin secret the site bucket requires, on origin-response the CORS and security headers are set.

module "edge" {
  source = "../../../../modules/lambda/lambda-edge-1.3"

  environment     = var.environment
  application     = var.application
  function_name   = "security-headers"
  source_template = "${path.module}/files/functions/security-headers.js"
  template_vars = {
    ALLOWED_ORIGIN = "https://${local.web_fqdn}"
    SECRET         = var.origin_secret
  }
}
