locals {
  name              = "${var.environment}-${var.application}"
  target_group_name = "${trimsuffix(substr(local.name, 0, 27), "-")}-${substr(sha1(join("|", [tostring(var.container_port), "HTTP", "ip", var.vpc_id])), 0, 4)}"
}
