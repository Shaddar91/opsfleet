#Route 53 hosted zone with its NS delegation in the parent zone; private when VPC ids are given.

resource "aws_route53_zone" "this" {
  name    = var.name
  comment = var.comment

  dynamic "vpc" {
    for_each = var.private_vpc_ids
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_route53_record" "delegation" {
  count = var.create_delegation && length(var.private_vpc_ids) == 0 ? 1 : 0

  zone_id = var.parent_zone_id
  name    = var.name
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.this.name_servers

  lifecycle {
    precondition {
      condition     = var.parent_zone_id != null
      error_message = "create_delegation needs parent_zone_id."
    }
  }
}
