locals {
  role_arn    = var.role == null ? module.role[0].role_arn : var.role.arn
  secret_arns = [for a in var.auth : a.secret_arn]
  db_user_arns = var.end_to_end_iam_auth == null ? [] : [
    for user in var.end_to_end_iam_auth.db_users :
    "arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current[0].account_id}:dbuser:${var.end_to_end_iam_auth.resource_id}/${user}"
  ]
  role_policy = templatefile("${path.module}/files/policies/rds-proxy.json", {
    SECRET_ARNS  = local.secret_arns
    DB_USER_ARNS = local.db_user_arns
    REGION       = data.aws_region.current.region
  })

  name       = "${var.environment}-${var.application}-pool"
  proxy_port = { MYSQL = 3306, POSTGRESQL = 5432, SQLSERVER = 1433 }[var.engine_family]
  #MYSQL covers MariaDB, which refuses MYSQL_CACHING_SHA2_PASSWORD, so MYSQL keeps the native default.
  client_password_auth_type = { MYSQL = "MYSQL_NATIVE_PASSWORD", POSTGRESQL = "POSTGRES_SCRAM_SHA_256", SQLSERVER = "SQL_SERVER_AUTHENTICATION" }[var.engine_family]
  session_pinning_filters   = var.session_pinning_filters != null ? var.session_pinning_filters : (var.engine_family == "MYSQL" ? ["EXCLUDE_VARIABLE_SETS"] : [])

  internal_records = var.internal_dns == null ? {} : {
    pool = { name = "${coalesce(var.internal_dns.name, var.application)}-pool", target = aws_db_proxy.main.endpoint }
  }
}
