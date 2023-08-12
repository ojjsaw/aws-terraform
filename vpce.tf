resource "aws_security_group" "dlwb_vpce_sg" {
  name   = "dlwb_vpce_sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "secret_manager" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"

  security_group_ids = [
    aws_security_group.dlwb_vpce_sg.id,
  ]
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(var.tags, {
    Name = "dlwb_secretmanager"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # works when 1 AZ, 1 private subnet, for multiple reference appropriate ids with manual creation
  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "dlwb_s3"
  })
}

resource "aws_vpc_endpoint" "dlwb_ecr_vpce" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.dlwb_vpce_sg.id,
  ]
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(var.tags, {
    Name = "dlwb_ecr"
  })
}

resource "aws_vpc_endpoint" "dlwb_dkr_vpce" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.dlwb_vpce_sg.id,
  ]
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(var.tags, {
    Name = "dlwb_dkr"
  })
}

resource "aws_vpc_endpoint" "dlwb_logs_vpce" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.dlwb_vpce_sg.id,
  ]
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(var.tags, {
    Name = "dlwb_logs"
  })
}

