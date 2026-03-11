resource "aws_launch_template" "ec2_lt" {
  name_prefix   = var.name_prefix != "" ? "${var.name_prefix}-${var.launch_template_name}" : var.launch_template_name
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_ami.id
  instance_type = var.instance_type
  user_data     = var.userdata
  key_name = var.key_pair != "" ? var.key_pair : null
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  network_interfaces {
    security_groups = var.security_group_ids
    associate_public_ip_address = false
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = var.name_prefix != "" ? "${var.name_prefix}-${var.asg_name}" : var.asg_name
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_block
  launch_template {
    id = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  target_group_arns = [var.tg_arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = var.name_prefix != "" ? "${var.name_prefix}-${var.asg_name}" : var.asg_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = { for k, v in var.tags : k => v if k != "Name" }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}
