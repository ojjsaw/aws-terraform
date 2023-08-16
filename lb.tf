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

  ingress {
    protocol    = "tcp"
    from_port   = 8888
    to_port     = 8888
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

resource "aws_lb_target_group" "client_alb_tg" {
  name        = "client-alb-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval = "30"
    protocol = "HTTP"
    path     = "/"
  }

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

resource "aws_lb_target_group" "omz_alb_tg" {
  name        = "omz-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval = "30"
    protocol = "HTTPS"
    path     = "/api/omz/swagger/spec.html"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "benchmark_alb_tg" {
  name        = "benchmark-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval = "30"
    protocol = "HTTPS"
    path     = "/api/benchmark/swagger/spec.html"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "project_alb_tg" {
  name        = "project-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval = "30"
    protocol = "HTTPS"
    path     = "/api/project/swagger/spec.html"
  }

  tags = var.tags
}

resource "aws_lb_listener" "alb_listener" {
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

resource "aws_lb_listener_rule" "client_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "sso_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sso_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/sso/*"]
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "omz_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.omz_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/omz/*"]
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "project_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/project/*"]
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "benchmark_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 97

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.benchmark_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/benchmark/*"]
    }
  }

  tags = var.tags
}

/* Network Load Balancer */
resource "aws_security_group" "nlb" {
  name   = "dlwb-nlb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 4222
    to_port     = 4222
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

resource "aws_lb" "nlb" {
  name               = "dlwb-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  #enable_cross_zone_load_balancing = true

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "bus_nlb_tg" {
  name        = "bus-nlb-tg"
  port        = 4222
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  tags = var.tags
}

resource "aws_lb_listener" "bus_nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 4222
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bus_nlb_tg.arn
  }

  tags = var.tags
}

output "nlb_ip_address" {
  value = aws_lb.alb.dns_name
}

output "alb_ip_address" {
  value = aws_lb.nlb.dns_name
}
