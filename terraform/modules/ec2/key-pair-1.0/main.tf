#EC2 key pair imported from one public key into every region in var.regions under the same name, so an instance in any of them can use it.
resource "aws_key_pair" "main" {
  for_each   = toset(var.regions)
  region     = each.value
  key_name   = var.key_name
  public_key = var.public_key
}
