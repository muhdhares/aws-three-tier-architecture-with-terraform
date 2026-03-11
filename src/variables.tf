variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string

}

variable "name_prefix" {
  description = "Optional prefix to prepend to resource names"
  type        = string

}

# variable "availability_zones" {
#   description = "Availabiliy Zones"
#   type        = list(string)
# }

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)

}

variable "vpc_cidr" {

}

variable "public_subnet_block" {

}

variable "private_subnet_block" {
  description = "Private Subnets"
  type        = list(string)

}

variable "instance_type" {

}

variable "ec2_role_name" {

}

variable "db_username" {

}


variable "db_name" {

}



variable "name_of_secret" {
  type = string

}

variable "db_identifier" {
  type = string

}

variable "password_length" {
  type = number

}

variable "bucket_name" {
  description = "Name of the S3 bucket for ALB access logs"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "owner" {
  description = "Owner or team responsible for these resources"
  type        = string
}