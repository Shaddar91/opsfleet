#No mail is ever sent or received for the zone name: null MX, hard-fail SPF, reject DMARC, revoked DKIM.

resource "aws_route53_record" "mx_null" {
  count = var.mail_lockdown ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = var.name
  type    = "MX"
  ttl     = 300
  records = ["0 ."]
}

resource "aws_route53_record" "spf" {
  count = var.mail_lockdown ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = var.name
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "dmarc" {
  count = var.mail_lockdown ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = "_dmarc.${var.name}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;"]
}

resource "aws_route53_record" "dkim_null" {
  count = var.mail_lockdown ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = "*._domainkey.${var.name}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; p="]
}
