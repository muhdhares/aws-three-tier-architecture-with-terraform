variable "aws_region" {}

variable "vpc_id" {}
variable "lifecycle_rule" {
  default = false
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default = 8
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the DB subnet group"
}

variable "availability_zone" {
  description = "The availability zone for the RDS instance"
  default = null
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Whether to create a Multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "security_groups" {}
variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to RDS resources"
  type        = map(string)
  default     = {}
}

variable "isPubliclyAccessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool 
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the RDS instance"
  type        = bool
  default     = false
}