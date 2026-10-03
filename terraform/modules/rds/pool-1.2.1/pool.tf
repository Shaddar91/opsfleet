#RDS Proxy with its default target group and one target, an RDS instance or an Aurora cluster.

resource "aws_db_proxy" "main" {
  name                   = local.name
  engine_family          = var.engine_family
  role_arn               = local.role_arn
  default_auth_scheme    = var.end_to_end_iam_auth == null ? "NONE" : "IAM_AUTH"
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = concat([aws_security_group.main.id], var.vpc_security_group_ids)
  require_tls            = var.require_tls
  idle_client_timeout    = var.idle_client_timeout
  debug_logging          = var.debug_logging

  dynamic "auth" {
    for_each = var.auth

    content {
      auth_scheme               = "SECRETS"
      secret_arn                = auth.value.secret_arn
      iam_auth                  = auth.value.iam_auth
      client_password_auth_type = coalesce(auth.value.client_password_auth_type, local.client_password_auth_type)
      description               = auth.value.description
    }
  }

  tags = {
    Name        = local.name
    Environment = var.environment
  }

  depends_on = [module.role]

  lifecycle {
    precondition {
      condition     = length(local.name) <= 63 && can(regex("^[a-z](-?[a-z0-9]+)*$", local.name))
      error_message = "The proxy name \"${local.name}\" must be at most 63 lowercase letters, digits and single hyphens, start with a letter and not end with a hyphen."
    }
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = local.session_pinning_filters
  }

  lifecycle {
    replace_triggered_by = [aws_db_proxy.main.id]
  }
}

resource "aws_db_proxy_target" "main" {
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
  db_instance_identifier = var.db_instance_identifier
  db_cluster_identifier  = var.db_cluster_identifier

  lifecycle {
    replace_triggered_by = [aws_db_proxy.main.id]
  }
}
