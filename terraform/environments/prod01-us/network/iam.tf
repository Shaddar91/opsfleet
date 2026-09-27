#Bastion instance role and profile: SSM Session Manager plus read on exactly the two Ansible objects the user-data pulls.

module "bastion_role" {
  source = "../../../modules/iam/role"

  environment      = var.environment
  application      = "bastion"
  aws_service      = "ec2.amazonaws.com"
  instance_profile = true
  policy_list      = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  custom_policy    = true
  policy_file = templatefile("${path.module}/files/policies/bastion-s3-read.json", {
    roles_object_arn    = "${local.ansible_bucket_arn}/${aws_s3_object.bastion_roles.key}"
    playbook_object_arn = "${local.ansible_bucket_arn}/${aws_s3_object.bastion_playbook.key}"
  })
}
