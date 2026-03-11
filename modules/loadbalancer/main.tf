resource "aws_lb" "alb" {
  name = var.name_prefix != "" ? "${var.name_prefix}-${var.alb_name}" : var.alb_name
  security_groups = var.security_groups
  load_balancer_type = "application"
  subnets = var.subnets
  internal = var.isInternal
  enable_deletion_protection = var.delete_protection
  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-${var.alb_name}" : var.alb_name })
  access_logs {
    bucket = var.bucket_id
    enabled = var.bucket_state
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-${var.tg_name}" : var.tg_name
  port        = var.lb_port
  protocol    = var.lb_protocol
  vpc_id      = var.vpc_id
  health_check {
    enabled = true
    interval = var.hc_interval
    port     = tostring(var.lb_port)
    path = var.hc_target
    timeout = var.timeout
    matcher = "200-299"
    healthy_threshold = var.health_threshold
    unhealthy_threshold = var.unhealth_threshold
  }

  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-${var.tg_name}" : var.tg_name })

}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = var.listener_port
  protocol = var.listener_protocol
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}


