resource "aws_ecs_task_definition" "dlwb_omz" {
  family                   = "dlwb-omz"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  depends_on               = [aws_ecs_service.dlwb_bus]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  # 0.25 vCPU
  cpu = 256
  # 1 GB
  memory = 1024
  container_definitions = jsonencode([
    {
      name      = "omz"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/applications.services.devcloud.workbench-omz:runtime"
      essential = true
      environment = [
        {
          name  = "COOKIE_NAME",
          value = "dlworkbench"
        },
        {
          name = "BUS_URL",
          value = "bus.dlwb:4222"
        }
      ]
      secrets = [
        {
          name      = "SECRET",
          valueFrom = "${var.COOKIE_SECRET}"
        },
        {
          name      = "CERT",
          valueFrom = "${var.TLS_CERT}"
        },
        {
          name      = "KEY",
          valueFrom = "${var.TLS_KEY}"
        }
      ]
      entrypoint = ["/bin/sh", "-c", "mkdir -p /var/run/secrets && echo \"$KEY\" > /var/run/secrets/tls_key && echo \"$CERT\" > /var/run/secrets/tls_cert && echo \"$SECRET\" > /var/run/secrets/cookie_secret && .venv/bin/python server.py --logging=debug --debug --port=443"]
      portMappings = [
        {
          containerPort = 443
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/dlwb/omz",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "dlwb_omz" {
  name            = "dlwb-omz"
  cluster         = aws_ecs_cluster.dlwb_fargate.id
  task_definition = aws_ecs_task_definition.dlwb_omz.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role.fargate_execution, aws_ecs_service.dlwb_bus]

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.dlwb_omz_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.omz_alb_tg.arn
    container_name   = "omz"
    container_port   = 443
  }

}

resource "aws_security_group" "dlwb_omz_sg" {
  name   = "dlwb_omz_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_a.cidr_block, aws_subnet.public_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.tags
}