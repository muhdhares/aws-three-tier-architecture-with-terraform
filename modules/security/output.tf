output "internet_alb_sg_id" {
  value = aws_security_group.internet_alb_sg.id
}

output "internet_alb_name" {
  value = aws_security_group.internet_alb_sg.name
}

output "frontend_sg_id" {
    value = aws_security_group.frontend_sg.id
}

output "frontend_sg_name" {
    value = aws_security_group.frontend_sg.name
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "backend_alb_sg_id" {
  value = aws_security_group.backend_alb_sg.id
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "bastion_sg_name" {
  value = aws_security_group.bastion_sg.name
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
