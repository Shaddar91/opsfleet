data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended/image_id"
}
