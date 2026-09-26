output "sg" {
  value = aws_security_group.main
}

output "sg_id" {
  value = aws_security_group.main.id
}