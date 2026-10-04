locals {
  config = {
    "global_cluster_identifier"                = local.global_cluster_identifier
    "standby_region"                           = var.standby_region
    "on_alarm"                                 = var.on_alarm
    "cluster_arn.${var.primary_region}"        = local.primary_cluster_arn
    "cluster_arn.${var.standby_region}"        = local.standby_cluster_arn
    "endpoint_group_arn.${var.primary_region}" = local.primary_endpoint_group_arn
    "endpoint_group_arn.${var.standby_region}" = local.standby_endpoint_group_arn
  }
}

locals {
  trigger_name = "${var.environment}-failover-regional-${var.primary_region}-unhealthy"

  #Global Accelerator metrics take the accelerator and listener ids, the path segments of the endpoint group ARN the function fences
  primary_endpoint_group_path = split("/", local.primary_endpoint_group_arn)
  primary_endpoint_group_dimensions = {
    Accelerator   = local.primary_endpoint_group_path[1]
    Listener      = local.primary_endpoint_group_path[3]
    EndpointGroup = var.primary_region
  }
}
