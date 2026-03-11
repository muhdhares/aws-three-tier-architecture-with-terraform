# Use it for SSH access to instances in private subnets

# resource "aws_instance" "bastion_host" {
#   ami                         = data.aws_ami.amazon_ami.id
#   instance_type               = var.instance_type
#   subnet_id                   = module.vpc.public_subnets[0]
#   security_groups             = [module.security.bastion_sg_id]
#   key_name                    = aws_key_pair.ec2_kp.key_name
#   associate_public_ip_address = true
#   tags                        = merge(local.tags, { Name = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-bastion" : "bastion" })
# }