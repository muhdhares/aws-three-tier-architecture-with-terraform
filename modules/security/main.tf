resource "aws_security_group" "internet_alb_sg" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-internet-alb-sg" : "internet-alb-sg"
  description = "Security group for internet facing ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Use this when you want to allow HTTPS traffic to the ALB
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-internet-alb-sg" : "internet-alb-sg" })
}

resource "aws_security_group" "frontend_sg" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-frontend-sg" : "frontend-sg"
  description = "Security group for frontend instances"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internet_alb_sg.id]
  }
  # allow SSH traffic only from bastion host security group
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-frontend-sg" : "frontend-sg" })
}

# bastion security group for SSH into instances
resource "aws_security_group" "bastion_sg" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-bastion-sg" : "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-bastion-sg" : "bastion-sg" })
}

# security group for internal backend ALB
resource "aws_security_group" "backend_alb_sg" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-backend-alb-sg" : "backend-alb-sg"
  description = "Security group for internal backend ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-backend-alb-sg" : "backend-alb-sg" })
}

# security group for backend instances
resource "aws_security_group" "backend_sg" {
  name        = var.name_prefix != "" ? "${var.name_prefix}-backend-sg" : "backend-sg"
  description = "Security group for backend instances"
  vpc_id      = var.vpc_id

  # allow traffic from internal backend ALB
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb_sg.id]
  }

  # allow SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.name_prefix != "" ? "${var.name_prefix}-backend-sg" : "backend-sg" })
}


resource "aws_security_group" "rds_sg" {
  name        = var.name_prefix
  description = "Security group for RDS"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}