variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "project_name" {
  type    = string
  default = "heavy-backend"
}
variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type        = string
  description = "Пароль для базы данных"
  sensitive   = true
}
variable "container_port" {
  type    = number
  default = 3000
}

variable "ecs_task_cpu" {
  type    = number
  default = 256
}

variable "ecs_task_memory" {
  type    = number
  default = 512
}

variable "api_desired_count" {
  type    = number
  default = 1
}

variable "alb_certificate_arn" {
  type        = string
  description = "ACM certificate ARN для HTTPS на ALB (в том же регионе, что и ALB)"
}

variable "cron_schedule_expression" {
  type        = string
  default     = "rate(5 minutes)"
  description = "Расписание EventBridge для cron-задачи"
}

