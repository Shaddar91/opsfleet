output "public_ip" {
  value = aws_instance.main.public_ip
}
output "private_ip" {
  value = aws_instance.main.private_ip
}

output "ec2_id" {
  value = aws_instance.main.id
}
