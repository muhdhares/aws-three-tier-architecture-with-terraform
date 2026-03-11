variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "name_prefix" {
  description = "Optional prefix for resource names"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to security resources"
  type        = map(string)
  default     = {}
}