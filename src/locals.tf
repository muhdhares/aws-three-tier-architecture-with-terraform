locals {
  # Private Subnets used in the project
  private_subnet_block_1 = slice(module.vpc.private_subnets, 0, 2)
  private_subnet_block_2 = slice(module.vpc.private_subnets, 2, 4)
  private_subnet_block_3 = slice(module.vpc.private_subnets, 4, 6)

  # Frontend userdata variables for EC2 instances, using template files to inject dynamic values such as account ID, region, and backend ALB DNS.
  frontend_userdata = templatefile("${path.module}/userdata/frontend.sh", {
    account         = data.aws_caller_identity.current.account_id
    region          = var.aws_region
    backend_alb_dns = module.backend_alb.alb_dns
  })

  # Backend userdata variables for EC2 instances, using template files to inject dynamic values such as region, account ID, and database details.
  backend_userdata = templatefile("${path.module}/userdata/backend.sh", {
    region       = var.aws_region
    account      = data.aws_caller_identity.current.account_id
    db_host      = module.aws_rds.address
    db_name      = var.db_name
    db_user      = var.db_username
    db_password  = random_password.rds_random_password.result
    frontend_url = "http://${module.frontend_alb.alb_dns}"
  })

  # Normalized name prefix: strip trailing hyphens to avoid double separators.
  name_prefix_clean = var.name_prefix != "" ? replace(var.name_prefix, "-+$", "") : ""

  # Convenience prefix with trailing hyphen when present (e.g. "myprefix-").
  name_prefix_with_sep = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-" : ""

  # Centralized tags for the entire deployment. Merge user-supplied `var.tags` with
  # standard tags derived from the root variables so modules receive a consistent map.
  tags = merge(var.tags, {
    Name        = local.name_prefix_clean
    Environment = var.environment
    Owner       = var.owner
  })
}


