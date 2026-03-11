variable "aws_region" {}

variable "vpc_id" {}
variable "lifecycle_rule" {
  default = false
}
variable "alb_name" {}
variable "listener_protocol" {
  default = "HTTP" 
}
variable "listener_port" {
  default = 80
}
variable "lb_port" {
  default = 80
}
variable "lb_protocol" {
  default = "HTTP"
}
variable "health_threshold" {
  default = 2
}
variable "unhealth_threshold" {
  default = 2
}
variable "timeout" {
  default = 3
}
variable "hc_target" {
  default = "/"
}
variable "hc_interval" {
  default = 30
}

variable "azs" {}
variable "security_groups" {}
variable "subnets" {}
variable "isInternal" {
  default = false
}
variable "delete_protection" {
  default = false
}
variable "tags" {
  default = {}
}

variable "name_prefix" {
  description = "Optional prefix for resource names"
  type        = string
  default     = ""
}

variable "tg_name" {}
variable "bucket_id" {default = ""}
variable "bucket_state" {
  default = false
}