#!/bin/bash
set -xe

REGION="${region}"
ACCOUNT="${account}"
BACKEND_DNS="${backend_alb_dns}"

# Update system
yum update -y

# Install Docker
yum install -y docker awscli

systemctl start docker
systemctl enable docker

# Allow ec2-user to run docker
usermod -aG docker ec2-user

# Login to ECR
aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${account}.dkr.ecr.${region}.amazonaws.com

# Create nginx config directory
mkdir -p /home/ec2-user/nginx

# Generate nginx.conf dynamically
cat <<EOF > /home/ec2-user/nginx/default.conf
server {
    listen 80;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://${backend_alb_dns};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Pull frontend image
docker pull ${account}.dkr.ecr.${region}.amazonaws.com/frontend:latest

# Run container
docker run -d \
  --name frontend \
  --restart unless-stopped \
  -p 80:80 \
  -v /home/ec2-user/nginx/default.conf:/etc/nginx/conf.d/default.conf \
  ${account}.dkr.ecr.${region}.amazonaws.com/frontend:latest