# output "subnets" {
#   value = module.vpc.private_subnets
# }

output "public_alb_dns" {
  value = module.frontend_alb.alb_dns
}

# output "db_name" {
#   value = module.aws_rds.db_name
# }

# output "rds_endp" {
#   value = module.aws_rds.db_endpoint
# }

# output "db_Address" {
#   value = module.aws_rds.address
# }

