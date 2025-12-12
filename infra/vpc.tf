# Получаем доступные зоны в регионе (eu-north-1)
data "aws_availability_zones" "available" {
  state = "available"
}

# Берём первые две зоны, чтобы не раздувать инфру
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

# Основная VPC
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-vpc"
  })
}
# Публичные сабнеты (для ALB и NAT)
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index)
  availability_zone = local.azs[count.index]

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-${count.index}"
    Tier = "public"
  })
}

# Приватные сабнеты (для ECS задач и базы)
resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index + length(local.azs))
  availability_zone = local.azs[count.index]

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-${count.index}"
    Tier = "private"
  })
}
# Интернет-шлюз для выхода наружу (public subnets)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-igw"
  })
}

# EIP для NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-nat-eip"
  })
}

# NAT Gateway в одном из public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-nat-gw"
  })

  depends_on = [aws_internet_gateway.igw]
}

# Маршрутная таблица для public subnets (через IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Маршрутная таблица для private subnets (через NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

