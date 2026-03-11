#!/bin/bash
set -xe

# Update & install Docker + AWS CLI
yum update -y
yum install -y docker awscli

systemctl start docker
systemctl enable docker

# Allow ec2-user to run docker
usermod -aG docker ec2-user

# Login to ECR
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${account}.dkr.ecr.${region}.amazonaws.com

# Pull backend image
docker pull ${account}.dkr.ecr.${region}.amazonaws.com/backend:latest

# Run backend container
docker run -d \
  --name backend \
  -p 3000:3000 \
  --restart unless-stopped \
  -e PORT=3000 \
  -e DB_HOST=${db_host} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_password} \
  -e DB_NAME=${db_name} \
  -e DB_SSL=true \
  -e FRONTEND_URL=${frontend_url} \
  ${account}.dkr.ecr.${region}.amazonaws.com/backend:latest

# Wait for app to start
sleep 15

# Basic health check
curl -f http://localhost:3000/health || docker logs backend


