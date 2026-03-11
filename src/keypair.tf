# Key pair resource for EC2 instances, using a public key from the local file system and tagging it appropriately.

resource "aws_key_pair" "ec2_kp" {
  key_name   = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-my-key" : "my-key"
  public_key = file("${path.module}/ssh_key/my-key.pub")
  tags       = merge(local.tags, { Name = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-my-key" : "my-key" })
}