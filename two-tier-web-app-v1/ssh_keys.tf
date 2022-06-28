###############################################
#  SSH EC2 PUBLIC key                         #
###############################################
resource "aws_key_pair" "ec2_public_key" {
  key_name   = "ec2_public_key"
  public_key = var.ssh_public_key
}
