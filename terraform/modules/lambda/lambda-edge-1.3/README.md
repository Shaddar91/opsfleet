# lambda-edge-1.3

One Lambda@Edge function: the code is rendered from `source_template` with `template_vars` (keys in CAPS, `${CAPS}` in the file) at plan time, zipped, published (`publish = true`, CloudFront needs a version), with an execution role that may only write logs, and a log group in us-east-1. The calling stack must run in us-east-1, where Lambda@Edge functions are created.

```terraform
module "origin_secret" {
  source = "../../../../modules/lambda/lambda-edge-1.3"

  environment     = var.environment
  application     = var.application
  function_name   = "origin-secret"
  source_template = "${path.module}/files/functions/security-headers.js"
  template_vars   = { ALLOWED_ORIGIN = "https://${local.web_fqdn}", SECRET = var.origin_secret }
}
```

`qualified_arn` is what a CloudFront `lambda_function_association` takes. A changed template publishes a new version and CloudFront picks it up on the next apply; the old version stays until CloudFront has let go of it, which can take hours, so a destroy right after a change may need a retry.
