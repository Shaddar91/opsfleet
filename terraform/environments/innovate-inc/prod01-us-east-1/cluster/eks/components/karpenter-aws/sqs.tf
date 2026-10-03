#Interruption queue EventBridge fills and Karpenter drains; the queue policy admits the two AWS services and refuses non-TLS calls.

module "interruption_queue" {
  source                  = "../../../../../../../modules/sqs/sqs-standard-1.1"
  enforce_tls             = true
  sqs_managed_sse_enabled = true
  create_dlq              = false

  environment                = var.environment
  application                = "karpenter"
  allowed_service_principals = local.interruption_queue.principals
  message_retention_seconds  = local.interruption_queue.retention_seconds
  tags                       = { Environment = var.environment }
}
