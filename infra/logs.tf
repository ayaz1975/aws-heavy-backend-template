# Логи для API сервиса
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${local.project_name}-api"
  retention_in_days = 14

  tags = local.common_tags
}

# Логи для worker
resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${local.project_name}-worker"
  retention_in_days = 14

  tags = local.common_tags
}

# Логи для cron
resource "aws_cloudwatch_log_group" "cron" {
  name              = "/ecs/${local.project_name}-cron"
  retention_in_days = 14

  tags = local.common_tags
}

