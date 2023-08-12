provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "dlwb"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "dlwb-igw"
  })
}

/* 2 public subnets */
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "dlwb-public-a"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "dlwb-public-b"
  })
}

/* 2 private subnets */
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "dlwb-private-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "dlwb-private-b"
  })
}

/* Routing tables */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "dlwb-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "dlwb-private-rt"
  })
}

/* Routing table associations */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_a.id

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_b.id

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_a.id

  depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "private_b" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_b.id

  depends_on = [aws_route_table.private]
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "dlwb-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "dlwb" {
  name = "/ecs/dlwb"

  tags = var.tags
}

resource "aws_ecs_cluster" "dlwb_fargate" {
  name       = "dlwb_fargate"
  depends_on = [aws_cloudwatch_log_group.dlwb]

  tags = var.tags
}