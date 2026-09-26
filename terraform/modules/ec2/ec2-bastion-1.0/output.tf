output "public_ip" {
  value = aws_instance.main.public_ip
}
output "private_ip" {
  value = aws_instance.main.private_ip
}
output "iam_profile" {
  value = aws_iam_instance_profile.ec2_profile
}
output "iam_role" {
  value = aws_iam_role.ec2_role
}

output "ec2_id" {
  value = aws_instance.main.id
}
