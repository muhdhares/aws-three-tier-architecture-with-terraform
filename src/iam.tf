# EC2 IAM Role and Instance Profile for ECR access and SSM management, along with S3 bucket policy for ALB access logs.

resource "aws_iam_role" "ec2_role" {
  name = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-${var.ec2_role_name}" : var.ec2_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecr_readonly_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = local.name_prefix_clean != "" ? "${local.name_prefix_clean}-ec2-ecr-instance-profile" : "ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_role.name
  tags = local.tags
}


# S3 bucket policy for ALB access logs
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.access_logs.arn}/*"
      }
    ]
  })
}