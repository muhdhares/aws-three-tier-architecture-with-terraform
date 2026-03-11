resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "rds-subnet-group"
  })
}


resource "aws_db_instance" "rds" {
  db_name                    = var.db_name
  identifier = var.db_identifier
  allocated_storage          = var.allocated_storage
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.name
  availability_zone          = var.availability_zone
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  multi_az                   = var.multi_az
  password                   = var.db_password
  username                   = var.db_username
  vpc_security_group_ids = var.security_groups
  skip_final_snapshot = true
  tags = var.tags
}
