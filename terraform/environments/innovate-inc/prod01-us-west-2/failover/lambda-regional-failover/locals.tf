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
