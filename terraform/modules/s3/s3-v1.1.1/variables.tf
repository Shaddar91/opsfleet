variable "bucket" {
  type        = string
  description = "Bucket name"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Let destroy delete the bucket while it still holds objects. A change takes effect only after an apply has stored it."
}

variable "policy" {
  default     = null
  description = "Bucket policy path/name."
}

variable "enable_website" {
  type        = bool
  description = "set to true in case s3 needs to serve a static website"
  default     = false
}
variable "index_document" {
  type        = string
  description = "suffix - (Required) A suffix that is appended to a request that is for a directory on the website endpoint. For example, if the suffix is index.html and you make a request to samplebucket/images/, the data that is returned will be for the object with the key name images/index.html. The suffix must not be empty and must not include a slash character."
  default     = null
}

variable "object_ownership" {
  type        = string
  description = "object_ownership - (Required) Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced BucketOwnerPreferred - Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL.ObjectWriter - Uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL. BucketOwnerEnforced - Bucket owner automatically owns and has full control over every object in the bucket. ACLs no longer affect permissions to data in the S3 bucket."
  default     = "BucketOwnerPreferred"
}

variable "error_document" {
  type        = string
  description = "key - (Required) The object key name to use when a 4XX class error occurs."
  default     = null
}

variable "key_prefix_equals" {
  type    = string
  default = null
}

variable "replace_key_prefix_with" {
  type    = string
  default = null
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Whether or not to enable access logs for the bucket"
}

variable "logging_target_bucket" {
  type        = string
  default     = null
  description = "If var.enable_logging is true then specify the name of the target bucket that'll store the logs here. If var.enable_logging is false then leave this as null."
}

variable "acl" {
  type        = string
  default     = "private"
  description = "The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, log-delivery-write, or another S3 canned ACL. Defaults to private. Conflicts with grant. Terraform will only perform drift detection if a configuration value is provided. Null applies no ACL; none is applied under BucketOwnerEnforced."
}

variable "bucket_versioning" {
  description = "Enable or Disable bucket versioning"
  type        = string
}

variable "lifecycle_rule" {
  type        = bool
  default     = false
  description = "Whether or not to enable LifeCycle rules. A configuration of object lifecycle management. See Lifecycle Rule below for details. Terraform will only perform drift detection if a configuration value is provided. Use the resource aws_s3_bucket_lifecycle_configuration instead"
}

variable "expire_after" {
  type        = number
  default     = null
  description = "Number of days before an object is deleted"
}

variable "noncurrent_days" {
  type        = number
  default     = null
  description = "Days a version stays noncurrent before it expires; current objects never expire. Null disables the rule. Independent of lifecycle_rule."
}

variable "newer_noncurrent_versions" {
  type        = number
  default     = null
  description = "Newest noncurrent versions per object kept past noncurrent_days. Needs noncurrent_days."
}

variable "abort_multipart_days" {
  type        = number
  default     = null
  description = "Days before an incomplete multipart upload is aborted. Null disables the rule. Independent of lifecycle_rule."
}

variable "prefix" {
  type        = string
  default     = ""
  description = "Prefix for logging and lifecycle"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to: 1.Reject calls to PUT Bucket policy if the specified bucket policy allows public access."
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should block public ACLs for this bucket. Defaults to false. Enabling this setting does not affect existing policies or ACLs. When set to true causes the following behavior: 1.PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. 2.PUT Object calls will fail if the request includes an object ACL."
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should ignore public ACLs for this bucket. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set. When set to true causes Amazon S3 to: 1.Ignore public ACLs on this bucket and any objects that it contains."
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked. When set to true: 1.Only the bucket owner and AWS Services can access this buckets if it has a public policy."
}

variable "enable_sse" {
  type        = bool
  default     = false
  description = "Whether to add an explicit server-side encryption configuration. When false, bucket uses AWS S3 default encryption (AES-256)."
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "Server-side encryption algorithm. Valid values: AES256 (SSE-S3) or aws:kms (SSE-KMS)."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for SSE-KMS encryption. Only used when sse_algorithm is aws:kms."
}

variable "transition_days" {
  type        = number
  default     = null
  description = "Number of days before transitioning objects to a different storage class. Set to null to disable. Needs lifecycle_rule = true."
}

variable "transition_storage_class" {
  type        = string
  default     = "STANDARD_IA"
  description = "Storage class to transition objects to. Valid values: STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE."
}

variable "object_lock" {
  type        = bool
  default     = false
  description = "Whether or not to enable Object Lock on the bucket. Only takes effect when the bucket is created"
}

variable "object_lock_mode" {
  type        = string
  default     = null
  description = "Default retention mode when Object Lock is enabled. Valid values are GOVERNANCE and COMPLIANCE."
}

variable "retention_years" {
  type        = number
  default     = null
  description = "The number of years that you want to specify for the default retention period when Object Lock is enabled"
}

variable "objects" {
  type = object({
    path  = string
    index = number
  })
  default     = null
  description = "Upload every file under path (ending in /) as an object. The key drops the first index path segments: files/objects/test.txt with index 2 becomes test.txt, with index 1 objects/test.txt."
}
