#Ships the bastion's Ansible roles (as a tarball) and playbook to the Ansible bucket; files/setup_script.sh pulls both at boot.

locals {
  bastion_playbook = "${path.module}/files/ansible/bastion.yml"
}

data "archive_file" "bastion_roles" {
  type             = "tar.gz"
  source_dir       = "${path.module}/files/ansible/roles"
  output_path      = "${path.module}/.terraform/bastion-roles.tar.gz"
  output_file_mode = "0666"
}

resource "aws_s3_object" "bastion_roles" {
  bucket      = local.ansible_bucket_name
  key         = "ansible/${var.environment}-${var.application}-roles.tar.gz"
  source      = data.archive_file.bastion_roles.output_path
  source_hash = data.archive_file.bastion_roles.output_sha256
}

resource "aws_s3_object" "bastion_playbook" {
  bucket      = local.ansible_bucket_name
  key         = "ansible-playbooks/${var.environment}-bastion.yml"
  source      = local.bastion_playbook
  source_hash = filesha256(local.bastion_playbook)
}
