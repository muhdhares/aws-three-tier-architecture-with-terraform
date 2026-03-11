terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
  # Use the S3 backend if you want remote state storage
  # backend "s3" {
  #   key    = "backend/tfstates"
  #   bucket = "3-tier-infra-alb-access-logs"
  #   region = "ap-south-1"
  # }
}