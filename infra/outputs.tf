output "vpc_id" {
  description = "ID основной VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Public subnets (ALB, NAT)"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  description = "Private subnets (ECS, DB)"
  value       = [for s in aws_subnet.private : s.id]
}

output "alb_dns_name" {
  description = "DNS имя ALB"
  value       = aws_lb.api.dns_name
}

output "api_https_url" {
  description = "HTTPS URL для API через ALB"
  value       = "https://${aws_lb.api.dns_name}"
}

output "db_endpoint" {
  description = "Endpoint PostgreSQL базы"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Имя базы данных"
  value       = aws_db_instance.this.db_name
}

