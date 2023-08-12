/* Application Load Balancer */
resource "aws_security_group" "alb" {
  name   = "dlwb-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_lb" "alb" {
  name               = "dlwb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "sso_alb_tg" {
  name        = "sso-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval = "30"
    protocol = "HTTPS"
    path     = "/api/sso/swagger/spec.html"
  }

  tags = var.tags
}

resource "aws_lb_listener" "sso_alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.CERTIFICATE

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sso_alb_tg.arn
  }

  tags = var.tags
}