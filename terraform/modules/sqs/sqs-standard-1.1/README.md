# sqs-standard-1.1

Standard SQS queue named `<environment>-<application>-queue`, its queue policy, and an optional encrypted dead-letter queue with a redrive policy.

The queue policy always allows the account root and `allowed_principal_arns` to use the queue. New in 1.1, both off by default so a caller moved from `sqs-standard` plans no change:

- `allowed_service_principals`: service principals (for example `events.amazonaws.com`) allowed to `sqs:SendMessage`.
- `enforce_tls`: adds a deny for every request not made over TLS.

Outputs: `sqs` and `dlq` (the queue resources), plus `arn`, `name` and `url` of the main queue.

```terraform
module "queue" {
  source                  = "../../modules/sqs/sqs-standard-1.1"
  enforce_tls             = true
  sqs_managed_sse_enabled = true
  create_dlq              = false

  environment                = var.environment
  application                = var.application
  allowed_service_principals = ["events.amazonaws.com"]
  message_retention_seconds  = 300
}
```
