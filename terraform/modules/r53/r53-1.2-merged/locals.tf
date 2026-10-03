locals {
  alias_target_set = try(length(var.resource_alias) > 0 && length(var.resource_zone) > 0, false)
  value_records    = try(length(var.records_list) > 0, false)
  create_record    = var.alias ? (var.skip_empty_alias_target ? local.alias_target_set : true) : local.value_records
}
