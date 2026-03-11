
# VPC module from Terraform
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-my-vpc" : "my-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = var.private_subnet_block
  public_subnets  = var.public_subnet_block

  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.tags
}

# Custom Security Group module for managing security groups for the ALBs, ASGs, and RDS instance.
module "security" {
  source      = "../modules/security"
  vpc_id      = module.vpc.vpc_id
  name_prefix = local.name_prefix_clean
  tags        = local.tags
}

# Custom Frontend and Backend ASG and ALB modules for managing the application load balancers and auto-scaling groups for the frontend and backend tiers, including configurations for target groups, listeners, health checks, and user data scripts.
module "frontend_alb" {
  source          = "../modules/loadbalancer"
  alb_name        = "frontend-alb"
  aws_region      = var.aws_region
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  tg_name         = "frontend-tg"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.security.internet_alb_sg_id]
  lb_port         = 80
  listener_port   = 80
  hc_target       = "/"
  name_prefix     = local.name_prefix_clean
  tags            = local.tags
  bucket_id       = aws_s3_bucket.access_logs.id
  bucket_state    = true
}
module "frontend_asg" {
  source               = "../modules/asg"
  asg_name             = "frontend-asg"
  vpc_id               = module.vpc.vpc_id
  launch_template_name = "frontend-ec2-lt"
  tg_arn               = module.frontend_alb.tg_arn
  private_subnet_block = local.private_subnet_block_1
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  instance_type        = var.instance_type
  userdata             = base64encode(local.frontend_userdata)
  key_pair             = aws_key_pair.ec2_kp.key_name
  security_group_ids   = [module.security.frontend_sg_id]
  name_prefix          = local.name_prefix_clean
  tags                 = local.tags
}

# Backend

module "backend_alb" {
  source          = "../modules/loadbalancer"
  alb_name        = "backend-alb"
  aws_region      = var.aws_region
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  tg_name         = "backend-tg"
  vpc_id          = module.vpc.vpc_id
  subnets         = local.private_subnet_block_2
  security_groups = [module.security.backend_alb_sg_id]
  lb_port         = 3000
  listener_port   = 80
  hc_target       = "/health"
  isInternal      = true
  name_prefix     = local.name_prefix_clean
  tags            = local.tags
  bucket_id       = aws_s3_bucket.access_logs.id
  bucket_state    = true
}
module "backend_asg" {
  source               = "../modules/asg"
  asg_name             = "backend-asg"
  vpc_id               = module.vpc.vpc_id
  launch_template_name = "backend-ec2-lt" 
  tg_arn               = module.backend_alb.tg_arn
  private_subnet_block = local.private_subnet_block_2
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  instance_type        = var.instance_type
  userdata             = base64encode(local.backend_userdata)
  key_pair             = aws_key_pair.ec2_kp.key_name
  security_group_ids   = [module.security.backend_sg_id]
  name_prefix          = local.name_prefix_clean
  tags                 = local.tags
}


# Custom RDS Module

module "aws_rds" {
  source          = "../modules/rds"
  db_identifier   = var.db_identifier
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = random_password.rds_random_password.result
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = local.private_subnet_block_3
  aws_region      = var.aws_region
  security_groups = [module.security.rds_sg_id]
  multi_az        = true
  tags            = local.tags
}
