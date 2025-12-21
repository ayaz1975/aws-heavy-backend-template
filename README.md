# AWS Heavy Backend Template (ECS + RDS + HTTPS)

Готовый шаблон для деплоя бэкенда на AWS:

- VPC + публичные / приватные сабнеты + NAT
- RDS PostgreSQL
- ECS Fargate:
  - API сервис
  - Worker сервис
  - Cron задачи через EventBridge
- ALB + HTTPS (ACM сертификат) + домен
- GitHub Actions:
  - build & push Docker образов в ECR
  - деплой новой версии через `aws ecs update-service`

---

## 1. Структура проекта

```text
aws-heavy-backend-template/
├── api/           # код API (Node.js, Express)
├── worker/        # фоновые задачи (worker)
├── cron/          # задачи по расписанию (cron job)
├── infra/         # Terraform инфраструктура (VPC, ECS, RDS, ALB, HTTPS)
└── .github/
    └── workflows/ # GitHub Actions (build & deploy)

