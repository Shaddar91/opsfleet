# global-accelerator-1.0-merged

AWS Global Accelerator: one accelerator, N listeners keyed by name, an optional endpoint group per listener, optional flow logs to S3, and an optional Route53 TCP health check on the accelerator DNS name.

## Usage

```hcl
module "global_accelerator" {
  source = "../../../modules/global-accelerator/global-accelerator-1.0-merged"

  environment = var.environment
  application = var.application

  listeners = {
    web = {
      port_ranges = [
        { from_port = 80, to_port = 80 },
        { from_port = 443, to_port = 443 },
      ]
      endpoint_group = {
        endpoints = [
          {
            endpoint_id                    = local.alb_arn
            client_ip_preservation_enabled = true
          },
        ]
      }
    }
  }
}
```

A listener with `endpoint_group = null` gets no endpoint group, so endpoints can be attached elsewhere. For ALB endpoints, Global Accelerator ignores the endpoint group's `health_check_*` settings and follows the ALB's target health.

## Inputs

| Name | Type | Default |
|------|------|---------|
| `environment`, `application` | `string` | required; name `<environment>-<application>-accelerator` |
| `accelerator_name` | `string` | `null` (derived name) |
| `enabled` | `bool` | `true` |
| `ip_address_type` | `string` | `IPV4` (`IPV4` or `DUAL_STACK`) |
| `flow_logs` | `object({ s3_bucket, s3_prefix })` | `null` (off); prefix `global-accelerator/` |
| `listeners` | `map(object)`, below | `{}` |
| `tags` | `map(string)` | `{}`, merged onto the accelerator and the health check |
| `create_route53_health_check` | `bool` | `false` |
| `route53_health_check_port` | `number` | `443` |
| `route53_health_check_failure_threshold` | `number` | `3` |
| `route53_health_check_request_interval` | `number` | `10` (`10` or `30`) |

Listener: `protocol` (`TCP`), `client_affinity` (`NONE`), `port_ranges` (required), `endpoint_group` (`null`).

Endpoint group: `region` (provider region), `health_check_protocol` (`TCP`; `TCP`, `HTTP` or `HTTPS`), `health_check_port` (`443`), `health_check_path` (`/`), `health_check_interval_seconds` (`30`; `10` or `30`), `threshold_count` (`3`), `traffic_dial_percentage` (`100`; 0 to 100), `endpoints` (required: `endpoint_id`, `weight` `100`, `client_ip_preservation_enabled` `true`).

## Outputs

| Name | Value |
|------|-------|
| `accelerator` | whole accelerator resource |
| `accelerator_arn`, `accelerator_id` | ARN, ID |
| `dns_name`, `hosted_zone_id` | Route53 alias target |
| `static_ip_addresses` | static IPs across all IP sets |
| `ip_sets` | raw IP sets |
| `listener_arns`, `listeners` | per listener key: ARN, whole resource |
| `endpoint_group_arns`, `endpoint_groups` | per listener key with an endpoint group: ARN, whole resource |
| `route53_health_check`, `route53_health_check_id` | whole resource, ID; `null` when off |

## Requirements

Terraform >= 1.3, hashicorp/aws >= 6.0.0.
