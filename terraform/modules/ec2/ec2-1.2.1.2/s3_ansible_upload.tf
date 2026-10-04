resource "aws_s3_object" "object" {
  bucket     = var.upload_location
  key        = var.s3_file_name
  content    = templatefile("files/ansible_playbook/${var.ansible_playbook_name}", var.template_vars)
  depends_on = [aws_instance.main]
}