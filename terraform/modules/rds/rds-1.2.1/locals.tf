locals {
  monitoring_role_name = "${local.identifier}-monitoring"

  internal_dns_name = var.internal_dns == null ? null : coalesce(var.internal_dns.name, var.application)
  internal_records = var.internal_dns == null ? {} : merge(
    { primary = { name = local.internal_dns_name, target = aws_db_instance.main.address } },
    { for i, suffix in local.replica_suffixes : suffix => { name = "${local.internal_dns_name}-${suffix}", target = aws_db_instance.replica[i].address } },
  )

  identifier             = coalesce(var.identifier, "${var.environment}-${var.application}")
  vpc_security_group_ids = concat([aws_security_group.main.id], var.vpc_security_group_ids)

  replica_suffixes    = [for i in range(var.read_replica_count) : i == 0 ? "ro" : "ro${i}"]
  replica_identifiers = [for suffix in local.replica_suffixes : "${local.identifier}-${suffix}"]
}
