variable "create_spot_service_linked_role" {
  description = "Create the account-wide EC2 Spot service-linked role, AWSServiceRoleForEC2Spot; false where the account already has it, or the create fails"
  type        = bool
}
