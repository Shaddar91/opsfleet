#CLOUDFRONT-scope web ACL in us-east-1; the distribution in main.tf attaches it through web_acl_id.

module "waf" {
  source = "../../../../modules/waf/cloudfront-waf-1.0"

  environment           = var.environment
  application           = var.application
  rate_limit            = var.waf_rate_limit
  evaluation_window_sec = var.waf_rate_window_sec
  log_retention_days    = var.waf_log_retention_days
}
