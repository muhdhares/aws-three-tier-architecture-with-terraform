# Data Source for getting the latest Amazon Linux 2023 AMI ID for x86_64 architecture.
data "aws_ami" "amazon_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}