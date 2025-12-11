# Правило EventBridge по расписанию (cron / rate)
resource "aws_cloudwatch_event_rule" "cron" {
  name                = "${local.project_name}-cron-rule"
  schedule_expression = var.cron_schedule_expression

  tags = local.common_tags
}

# Target: запуск ECS задачи cron по расписанию
resource "aws_cloudwatch_event_target" "cron" {
  rule      = aws_cloudwatch_event_rule.cron.name
  target_id = "run-cron-task"
  arn       = aws_ecs_cluster.this.arn
  role_arn  = aws_iam_role.events_to_ecs.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.cron.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets         = [for s in aws_subnet.private : s.id]
      security_groups = [aws_security_group.ecs_tasks.id]
      assign_public_ip = false
    }
  }
}

