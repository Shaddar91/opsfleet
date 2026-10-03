locals {
  name = "${var.environment}-${var.application}"

  #one endpoint group per listener and region, keyed "<listener>/<region>"
  endpoint_groups = merge([
    for lk, l in var.listeners : {
      for region, g in l.endpoint_groups : "${lk}/${region}" => merge(g, { listener = lk, region = region })
    }
  ]...)
}
