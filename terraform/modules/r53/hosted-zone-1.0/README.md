# hosted-zone-1.0

One Route 53 hosted zone. Public by default, with its NS delegation written into `parent_zone_id`; private when `private_vpc_ids` names the VPCs it answers in, and then nothing delegates to it. With `mail_lockdown` (default on) the zone also carries the records that refuse all mail for its name: a null MX, `v=spf1 -all`, a reject DMARC and a revoked DKIM wildcard.

Outputs `zone_id`, `name`, `name_servers`, `arn` and `private`, so any stack or project reads the zone from this state.

```terraform
module "public_zone" {
  source            = "../../../modules/r53/hosted-zone-1.0"
  create_delegation = true
  mail_lockdown     = true

  name           = "of.example.com"
  parent_zone_id = data.aws_route53_zone.parent.zone_id
}
```
