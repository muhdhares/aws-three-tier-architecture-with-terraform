variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {}

variable "asg_name" {
  default = "asg"
}
variable "min_size" {
  default = 2
}
variable "max_size" {
  default = 4
}
variable "desired_capacity" {
  default = 2
}

variable "private_subnet_block" {}

variable "tg_arn" {}

variable "launch_template_name" {}

variable "ami_id" {
  description = "AMI ID for the EC2 instances in the ASG"
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "userdata" {}

variable "iam_instance_profile" {}

variable "key_pair" {
  default = ""
}

variable "security_group_ids" {}


variable "tags" {
  default = {}
}

variable "name_prefix" {
  description = "Optional prefix for resource names"
  type        = string
  default     = ""
}