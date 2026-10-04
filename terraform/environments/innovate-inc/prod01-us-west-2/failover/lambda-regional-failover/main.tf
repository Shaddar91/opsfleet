#innovate-inc regional failover: the of-failover function in the standby region (region in terraform.tfvars) that sets a region's accelerator dial to 0 and promotes the Aurora global database standby; what it may touch comes from secrets.tf and files/policies/failover.json.

module "failover" {
  source = "../../../../../modules/lambda/lambda-1.2"

  environment   = var.environment
  application   = "failover"
  function_name = "regional"
  description   = "Fences a region on the accelerator and promotes the Aurora global database standby; invoke with {\"action\":\"status\"} first"
  image_uri     = "${local.image_repository_url}:${var.image_tag}"
  architecture  = "arm64"
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment_variables = {
    FAILOVER_SECRET_ARN = module.config.arn
  }

  policy_file = templatefile("${path.module}/files/policies/failover.json", {
    GLOBAL_CLUSTER_ARN         = local.global_cluster_arn
    PRIMARY_CLUSTER_ARN        = local.primary_cluster_arn
    STANDBY_CLUSTER_ARN        = local.standby_cluster_arn
    PRIMARY_ENDPOINT_GROUP_ARN = local.primary_endpoint_group_arn
    STANDBY_ENDPOINT_GROUP_ARN = local.standby_endpoint_group_arn
    SECRET_ARN                 = module.config.arn
  })
}
