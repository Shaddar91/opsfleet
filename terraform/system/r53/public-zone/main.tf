#Public Route53 zone for var.domain_name, with the optional null-mail SPF and DMARC records.

resource "aws_route53_zone" "public" {
  name              = var.domain_name
  force_destroy     = var.force_destroy
  delegation_set_id = var.delegation_set_id
}

locals {
  null_mail_records = {
    spf   = { name = var.domain_name, value = "v=spf1 -all" }
    dmarc = { name = "_dmarc.${var.domain_name}", value = "v=DMARC1; p=reject" }
  }
}

module "null_mail" {
  source   = "../../../modules/r53/r53-1.2-merged"
  for_each = { for k, v in local.null_mail_records : k => v if var.null_mail }

  zone_id            = aws_route53_zone.public.zone_id
  domain_name        = each.value.name
  type_of_dns_record = "TXT"
  records_list       = [each.value.value]
}
