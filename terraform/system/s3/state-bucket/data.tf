data "aws_s3_bucket" "existing" {
  count  = var.create_state_bucket ? 0 : 1
  bucket = var.state_bucket_name

  lifecycle {
    postcondition {
      condition     = self.bucket_region == var.region
      error_message = "The existing state bucket is in ${self.bucket_region}, not ${var.region}: set STATE_BUCKET_REGION=${self.bucket_region}."
    }
  }
}
