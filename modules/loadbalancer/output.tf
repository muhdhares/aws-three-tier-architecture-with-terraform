output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_name" {
  value = aws_lb.alb.name
}

output "tg_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}