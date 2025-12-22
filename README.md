# AWS Backend Deployment on AWS (ECS Fargate + RDS + HTTPS)

**Service:** I deploy backend applications to AWS with ECS Fargate, PostgreSQL (RDS), HTTPS, custom domain, and CI/CD.

This repository is my production-ready reference implementation used to deliver client deployments quickly and consistently.

## What you get (deliverables)
- VPC (public/private subnets) + NAT
- RDS PostgreSQL
- ECS Fargate services:
  - API service (Node.js / Express)
  - Worker service (background jobs)
  - Scheduled Cron tasks via EventBridge (RunTask)
- Application Load Balancer (ALB) + HTTPS (ACM certificate) + custom domain
- GitHub Actions CI/CD:
  - Build & push Docker images to ECR
  - Deploy new version via `aws ecs update-service`

## Repository structure
```text
aws-heavy-backend-template/
├─ api/        # API code (Node.js, Express)
├─ worker/     # background jobs (worker)
├─ cron/       # scheduled jobs (cron)
├─ infra/      # Terraform (VPC, ECS, RDS, ALB, HTTPS)
└─ .github/
   └─ workflows/  # GitHub Actions (build & deploy)
