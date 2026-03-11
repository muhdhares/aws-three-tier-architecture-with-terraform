# Data sources to get the names of Availability Zones in the selected region.
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Data Source for getting the latest Amazon Linux 2023 AMI ID for x86_64 architecture.
# data "aws_ami" "amazon_ami" {
#   owners      = ["amazon"]
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-kernel-6.1-x86_64"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}
