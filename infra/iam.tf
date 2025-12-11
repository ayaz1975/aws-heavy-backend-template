# Trust policy для ECS задач (кто может AssumeRole)
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Execution role — для скачивания образов из ECR и логов в CloudWatch
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.project_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role — то, что внутри контейнера (доступ к AWS сервисам при необходимости)
resource "aws_iam_role" "ecs_task" {
  name               = "${local.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = local.common_tags
}
# Trust policy для EventBridge (events.amazonaws.com)
data "aws_iam_policy_document" "events_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Роль, от имени которой EventBridge будет вызывать ECS RunTask
resource "aws_iam_role" "events_to_ecs" {
  name               = "${local.project_name}-events-to-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.events_assume.json

  tags = local.common_tags
}

# Политика: разрешаем RunTask и PassRole
data "aws_iam_policy_document" "events_to_ecs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:RunTask",
      "ecs:DescribeTasks",
      "iam:PassRole"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "events_to_ecs" {
  name   = "${local.project_name}-events-to-ecs-policy"
  role   = aws_iam_role.events_to_ecs.id
  policy = data.aws_iam_policy_document.events_to_ecs_policy.json
}

