variable "environment" {
  type        = string
  description = "Environment name, the first part of every resource name"
}

variable "application" {
  type        = string
  description = "Application name, the second part of every resource name and the default internal record name"
}

variable "engine_family" {
  type        = string
  description = "MYSQL (RDS for MySQL and MariaDB, Aurora MySQL), POSTGRESQL (RDS for PostgreSQL, Aurora PostgreSQL) or SQLSERVER"

  validation {
    condition     = contains(["MYSQL", "POSTGRESQL", "SQLSERVER"], var.engine_family)
    error_message = "engine_family must be MYSQL, POSTGRESQL or SQLSERVER."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC of the proxy security group, the VPC of the database"
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Subnets of the proxy, in at least two availability zones"
}

variable "db_instance_identifier" {
  type        = string
  default     = null
  description = "RDS instance behind the proxy; set exactly one of db_instance_identifier and db_cluster_identifier"

  validation {
    condition     = (var.db_instance_identifier == null) != (var.db_cluster_identifier == null)
    error_message = "Set exactly one of db_instance_identifier (an RDS instance) and db_cluster_identifier (an Aurora cluster)."
  }
}

variable "db_cluster_identifier" {
  type        = string
  default     = null
  description = "Aurora cluster behind the proxy; set exactly one of db_instance_identifier and db_cluster_identifier"
}

variable "db_port" {
  type        = number
  description = "Port the database listens on; the proxy itself listens on 3306 (MYSQL), 5432 (POSTGRESQL) or 1433 (SQLSERVER)"
}

variable "target_security_group_id" {
  type        = string
  description = "Security group of the database; the module adds its ingress rule from the proxy on db_port"
}

variable "auth" {
  type = list(object({
    secret_arn                = string
    iam_auth                  = optional(string, "DISABLED")
    client_password_auth_type = optional(string)
    description               = optional(string)
  }))
  default     = []
  nullable    = false
  description = "One Secrets Manager secret per database user; client_password_auth_type null takes the engine family default. Required unless end_to_end_iam_auth is set"

  validation {
    condition     = length(var.auth) > 0 || var.end_to_end_iam_auth != null
    error_message = "auth needs at least one secret unless end_to_end_iam_auth is set: AWS requires Auth when DefaultAuthScheme is NONE."
  }
  validation {
    condition     = alltrue([for a in var.auth : contains(["DISABLED", "REQUIRED"], a.iam_auth) || (a.iam_auth == "ENABLED" && var.engine_family == "SQLSERVER")])
    error_message = "auth[*].iam_auth must be DISABLED or REQUIRED; ENABLED is valid only with engine_family SQLSERVER."
  }
  validation {
    condition = alltrue([for a in var.auth : a.client_password_auth_type == null || contains(lookup({
      MYSQL      = ["MYSQL_NATIVE_PASSWORD", "MYSQL_CACHING_SHA2_PASSWORD"]
      POSTGRESQL = ["POSTGRES_SCRAM_SHA_256", "POSTGRES_MD5"]
      SQLSERVER  = ["SQL_SERVER_AUTHENTICATION"]
    }, var.engine_family, []), a.client_password_auth_type)])
    error_message = "auth[*].client_password_auth_type must fit engine_family: MYSQL_NATIVE_PASSWORD or MYSQL_CACHING_SHA2_PASSWORD for MYSQL, POSTGRES_SCRAM_SHA_256 or POSTGRES_MD5 for POSTGRESQL, SQL_SERVER_AUTHENTICATION for SQLSERVER."
  }
}

variable "end_to_end_iam_auth" {
  type = object({
    resource_id = string
    db_users    = list(string)
  })
  default     = null
  description = "End-to-end IAM authentication (default auth scheme IAM_AUTH): the target's resource ID (instance resource_id or cluster_resource_id) and the database users the proxy connects as. null keeps the secrets scheme"

  validation {
    condition     = var.end_to_end_iam_auth == null || var.engine_family != "SQLSERVER"
    error_message = "end_to_end_iam_auth is not available for SQLSERVER: RDS Proxy does not support end-to-end IAM authentication for RDS for SQL Server."
  }
  validation {
    condition     = try(length(var.end_to_end_iam_auth.db_users) > 0, true)
    error_message = "end_to_end_iam_auth.db_users needs at least one database user."
  }
}

variable "role" {
  type = object({
    arn = string
  })
  default     = null
  description = "Existing proxy role; null creates one. An object, so an ARN unknown at plan keeps the role count known"
}

variable "require_tls" {
  type        = bool
  default     = true
  nullable    = false
  description = "Refuse client connections without TLS"
}

variable "idle_client_timeout" {
  type        = number
  default     = 1800
  nullable    = false
  description = "Seconds an idle client connection stays open"
}

variable "debug_logging" {
  type        = bool
  default     = false
  nullable    = false
  description = "Log SQL statement text; debugging only"
}

variable "connection_borrow_timeout" {
  type        = number
  default     = 120
  nullable    = false
  description = "Seconds a client waits for a pooled connection once the pool is exhausted"

  validation {
    condition     = var.connection_borrow_timeout >= 0 && var.connection_borrow_timeout <= 300
    error_message = "connection_borrow_timeout must be between 0 and 300 seconds (ConnectionPoolConfiguration API)."
  }
}

variable "init_query" {
  type        = string
  default     = null
  description = "SQL the proxy runs on each new database connection; null runs none. Visible to anyone who can read the target group, so never put secrets in it"
}

variable "max_connections_percent" {
  type        = number
  default     = 50
  nullable    = false
  description = "Pool size as a percentage of the database max_connections"
}

variable "max_idle_connections_percent" {
  type        = number
  default     = 25
  nullable    = false
  description = "Idle connections kept open, as a percentage of the database max_connections"

  validation {
    condition     = var.max_idle_connections_percent <= var.max_connections_percent
    error_message = "max_idle_connections_percent must not exceed max_connections_percent."
  }
}

variable "session_pinning_filters" {
  type        = list(string)
  default     = null
  description = "SQL operation classes exempt from pinning; null gives [\"EXCLUDE_VARIABLE_SETS\"] for MYSQL and none otherwise"

  validation {
    condition     = try(length(var.session_pinning_filters), 0) == 0 || var.engine_family == "MYSQL"
    error_message = "session_pinning_filters are supported only for engine_family MYSQL."
  }
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Security groups the proxy security group admits on the proxy port"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "IPv4 CIDR blocks the proxy security group admits on the proxy port"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Extra security groups attached next to the proxy security group"
}

variable "secrets_manager_egress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  nullable    = false
  description = "IPv4 CIDR blocks the proxy reaches on 443 for Secrets Manager; the VPC CIDR is enough behind a Secrets Manager VPC endpoint"
}

variable "internal_dns" {
  type = object({
    zone_id = string
    name    = optional(string)
    ttl     = optional(number, 300)
  })
  default     = null
  description = "Private hosted zone for the CNAME <name>-pool; name defaults to application. null creates no record"

  validation {
    condition     = var.internal_dns == null || try(var.internal_dns.zone_id != "", true)
    error_message = "internal_dns.zone_id must not be empty; pass internal_dns = null for no records."
  }
}
