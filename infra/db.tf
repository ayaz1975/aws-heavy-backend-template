# Параметр-группа для PostgreSQL (отключаем принудительный SSL)
resource "aws_db_parameter_group" "this" {
  name   = "${local.project_name}-pg"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = local.common_tags
}

# Subnet group для базы (только private subnets)
resource "aws_db_subnet_group" "this" {
  name       = "${local.project_name}-db-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-db-subnets"
  })
}

# Security Group для базы
resource "aws_security_group" "db" {
  name        = "${local.project_name}-db-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.this.id

  # Разрешаем доступ к базе только с ECS задач
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Исходящий трафик (из базы наружу, например на бэкапы)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# RDS PostgreSQL инстанс
resource "aws_db_instance" "this" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = "db.t4g.micro"

  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Используем нашу параметр-группу (без принудительного SSL)
  parameter_group_name = aws_db_parameter_group.this.name

  publicly_accessible  = false
  multi_az             = false
  storage_type         = "gp3"
  skip_final_snapshot  = true
  deletion_protection  = false

  tags = local.common_tags
}
