# Three-Tier AWS Architecture

## Table of Contents

- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Architecture Overview](#architecture-overview)
- [Architecture Flow](#architecture-flow)
  - [Client → Internet ALB](#1-client--internet-alb)
  - [Internet ALB → Frontend ASG](#2-internet-alb--frontend-asg)
  - [Frontend → Internal ALB](#3-frontend--internal-alb)
  - [Internal ALB → Backend ASG](#4-internal-alb--backend-asg)
  - [Backend → RDS Database](#5-backend--rds-database)
- [Core Infrastructure Components](#core-infrastructure-components)
  - [VPC and Networking](#vpc-and-networking)
  - [Application Load Balancers](#application-load-balancers)
  - [Auto Scaling Groups](#auto-scaling-groups)
  - [Amazon RDS](#amazon-rds)
  - [Security Groups](#security-groups)
  - [S3 (ALB Access Logs)](#s3-alb-access-logs)
- [Repository Structure](#repository-structure)
- [Deployment Guide](#deployment-guide)
  - [Prerequisites](#prerequisites)
- [Build and Push Docker Images](#build-and-push-docker-images)
- [Terraform Deployment](#terraform-deployment)
- [User Data Configuration](#user-data-configuration)
- [Operational Notes and Troubleshooting](#operational-notes-and-troubleshooting)
- [Future Improvements](#future-improvements)
- [Author](#author)

## Project Overview

This project demonstrates a production-style **Three-Tier Web Application Architecture on AWS** deployed using **Terraform Infrastructure as Code (IaC)**.

The architecture separates the application into three logical layers:

* **Presentation Layer (Frontend)**
* **Application Layer (Backend)**
* **Data Layer (Database)**

All infrastructure components are provisioned using **modular Terraform code** to ensure reproducibility, scalability, and maintainability.

### Technologies Used

* Terraform (Infrastructure as Code)
* AWS EC2
* AWS Auto Scaling Groups
* AWS Application Load Balancer (ALB)
* Amazon RDS (MySQL)
* Amazon S3 (ALB access logging)
* Amazon ECR (Docker image storage)
* Docker
* Nginx (Frontend)
* Node.js (Backend)

---

# Architecture Overview

The system follows a **secure multi-layer architecture** where only the entry load balancer is exposed to the internet, while all application and database components remain isolated inside private subnets.

```
Client
  │
  ▼
Internet-facing Application Load Balancer
(Public Subnets)
  │
  ▼
Frontend Auto Scaling Group
(Private Subnets)
  │
  ▼
Internal Application Load Balancer
(Private Subnets)
  │
  ▼
Backend Auto Scaling Group
(Private Subnets)
  │
  ▼
Amazon RDS Database
(Private Subnets)
```

This design improves:

* Security
* Scalability
* Fault tolerance
* Network isolation

---

# Architecture Flow

### 1. Client → Internet ALB

External users access the application through an **internet-facing Application Load Balancer** deployed in public subnets.

Responsibilities:

* Entry point for HTTP/HTTPS traffic
* Performs health checks
* Distributes requests to frontend instances

---

### 2. Internet ALB → Frontend ASG

The external ALB forwards requests to the **Frontend Auto Scaling Group**.

Frontend EC2 instances:

* Run a **Docker container with Nginx**
* Serve static web assets
* Proxy API calls to backend services

---

### 3. Frontend → Internal ALB

Frontend instances communicate with the backend via an **internal Application Load Balancer**.

Characteristics:

* Not accessible from the internet
* Only accessible inside the VPC
* Routes traffic to backend services

---

### 4. Internal ALB → Backend ASG

The internal ALB distributes requests to the **Backend Auto Scaling Group**.

Backend EC2 instances:

* Run a **Node.js API container**
* Process application logic
* Communicate with the database layer

---

### 5. Backend → RDS Database

Backend services store and retrieve data from **Amazon RDS (MySQL)**.

Features:

* Deployed inside private subnets
* Multi-AZ for high availability
* Accessible only from backend security group

---

# Core Infrastructure Components

## VPC and Networking

A custom **Virtual Private Cloud (VPC)** is created with multiple subnets.

### Public Subnets

Used for:

* Internet-facing ALB
* Internet Gateway access

### Private Subnets

Used for:

* Frontend EC2 instances
* Backend EC2 instances
* Internal ALB
* Amazon RDS

### Nat Gateway

Used for:

* SSH access to private EC2 and to connect private resources with internet

This setup ensures backend systems are not directly reachable from the internet.

---

## Application Load Balancers

Two ALBs are used.

### Internet ALB

Purpose:

* Accept traffic from the internet
* Route requests to frontend instances

### Internal ALB

Purpose:

* Handle internal service communication
* Route frontend API requests to backend services

---

## Auto Scaling Groups

Two independent **Auto Scaling Groups** manage compute resources.

### Frontend ASG

* Hosts Nginx containers
* Serves static content
* Proxies API calls

### Backend ASG

* Runs Node.js application containers
* Handles business logic
* Connects to RDS database

Auto Scaling provides:

* Automatic scaling based on load
* Fault tolerance
* Instance replacement on failure

---

## Amazon RDS

The database layer uses **Amazon RDS for MySQL**.

Configuration includes:

* Multi-AZ deployment
* Private subnet placement
* Security group restrictions
* Automated backups

Only backend services can access the database.

---

## Security Groups

Security groups enforce strict communication rules between layers.

Examples:

Internet ALB SG

* Allow HTTP/HTTPS from internet

Frontend SG

* Allow traffic only from Internet ALB

Internal ALB SG

* Allow traffic from frontend instances

Backend SG

* Allow traffic only from internal ALB

RDS SG

* Allow database access only from backend instances

This layered security model prevents unauthorized access.

---

## S3 (ALB Access Logs)

An optional **Amazon S3 bucket** is used to store:

* Application Load Balancer access logs

Benefits:

* Request auditing
* Traffic analysis
* Security monitoring

---

# Repository Structure

```
.
├── README.md
├── app
│   ├── backend
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src
│   │       ├── db.js
│   │       ├── initDB.js
│   │       ├── routes.js
│   │       └── server.js
│   │
│   └── frontend
│       ├── Dockerfile
│       ├── nginx.conf
│       └── public
│           ├── app.js
│           ├── index.html
│           └── style.css
│
├── modules
│   ├── asg
│   ├── loadbalancer
│   ├── rds
│   └── security
│
└── src
    ├── main.tf
    ├── variables.tf
    ├── locals.tf
    ├── provider.tf
    ├── iam.tf
    ├── bucket.tf
    ├── keypair.tf
    ├── secrets.tf
    ├── bastion.tf
    ├── terraform.tf
    └── userdata
        ├── frontend.sh
        └── backend.sh
```

---

# Deployment Guide

## Prerequisites

Ensure the following tools are installed:

* AWS CLI
* Terraform
* Docker
* Git

Configure AWS credentials:

```
aws configure
```

---

# Build and Push Docker Images

Create two ECR repositories:

```
frontend
backend
```

Build images:

```
docker build -t frontend ./app/frontend
docker build -t backend ./app/backend
```

Login to ECR:

```
aws ecr get-login-password --region <region> \
| docker login --username AWS \
--password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
```

Tag images:

```
docker tag frontend:latest <account_id>.dkr.ecr.<region>.amazonaws.com/frontend:latest
docker tag backend:latest <account_id>.dkr.ecr.<region>.amazonaws.com/backend:latest
```

Push images:

```
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/frontend:latest
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/backend:latest
```

---

# Terraform Deployment

Run Terraform from the **src directory**.

Initialize Terraform:

```
terraform init
```

Create an execution plan:

```
terraform plan -out plan.tfplan
```

Apply infrastructure:

```
terraform apply "plan.tfplan"
```

Terraform will provision all AWS resources including networking, compute, load balancers, and the database.

---

# User Data Configuration

The EC2 instances use **user-data scripts** located in:

```
src/userdata/frontend.sh
src/userdata/backend.sh
```

Terraform dynamically injects values such as:

* AWS account ID
* AWS region
* Backend ALB DNS name
* RDS endpoint

This is handled using Terraform's `templatefile()` function in `locals.tf`.

---

# Operational Notes and Troubleshooting

Common checks if the application does not work:

### Check ALB Target Health

Verify that targets in both ALBs are healthy.

### Check EC2 Logs

On instances:

```
sudo docker ps
sudo docker logs <container_id>
```

### Check System Logs

```
sudo journalctl -xe
```

### Check Security Groups

Ensure that the correct ports are open between architecture layers.

---

# Future Improvements

Possible enhancements to this project:

* Migrate containers to **Amazon ECS or EKS**
* Add **CI/CD pipeline for automatic Docker builds**
* Implement **Terraform remote state (S3 + DynamoDB)**
* Add **CloudWatch monitoring and alarms**
* Integrate **HTTPS using ACM and Route53**
* Add **centralized logging**

---

# Author

Mohammad Haris

Cloud / DevOps Engineer
