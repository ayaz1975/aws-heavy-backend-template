aws_region   = "eu-north-1"
project_name = "joon-backend"

db_name     = "joon_appdb"
db_username = "joon_user"
db_password = "ChangeMeStrong123!"

container_port   = 3000
ecs_task_cpu     = 256
ecs_task_memory  = 512

api_desired_count        = 1
cron_schedule_expression = "rate(1 day)"

