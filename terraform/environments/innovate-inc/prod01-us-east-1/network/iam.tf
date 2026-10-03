#Bastion instance role and profile: SSM Session Manager plus read on exactly the two Ansible objects the user-data pulls.

module "bastion_role" {
  source           = "../../../../modules/iam/role"
  instance_profile = true
  custom_policy    = true

  environment = var.environment
  application = "bastion"
  aws_service = "ec2.amazonaws.com"
  policy_list = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  policy_file = templatefile("${path.module}/files/policies/bastion-s3-read.json", {
    ROLES_OBJECT_ARN    = "${local.ansible_bucket_arn}/${aws_s3_object.bastion_roles.key}"
    PLAYBOOK_OBJECT_ARN = "${local.ansible_bucket_arn}/${aws_s3_object.bastion_playbook.key}"
  })
}
