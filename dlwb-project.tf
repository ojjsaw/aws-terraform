resource "aws_ecs_task_definition" "dlwb_project" {
  family                   = "dlwb-project"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  depends_on               = [aws_lb.nlb, aws_ecs_service.dlwb_bus]
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
      name      = "project"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/applications.services.devcloud.workbench-project:runtime"
      essential = true
      environment = [
        {
          name  = "COOKIE_NAME",
          value = "dlworkbench"
        },
        {
          name  = "BUS_URL",
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
        },
        {
          name      = "PEM",
          valueFrom = "${var.TLS_PEM}"
        },
        {
          name      = "DB",
          valueFrom = "${var.ATLAS_URL}"
        }
      ]
      entrypoint = ["/bin/sh", "-c", "mkdir -p /var/run/secrets && echo \"$KEY\" > /var/run/secrets/tls_key && echo \"$CERT\" > /var/run/secrets/tls_cert && echo \"$SECRET\" > /var/run/secrets/cookie_secret && echo \"$PEM\" > /var/run/secrets/tls_pem && .venv/bin/python server.py --logging=debug --debug --port=443 --db=\"$DB\""]
      portMappings = [
        {
          containerPort = 443
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/dlwb/project",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "dlwb_project" {
  name            = "dlwb-project"
  cluster         = aws_ecs_cluster.dlwb_fargate.id
  task_definition = aws_ecs_task_definition.dlwb_project.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role.fargate_execution, aws_ecs_service.dlwb_bus]

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.dlwb_project_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.project_alb_tg.arn
    container_name   = "project"
    container_port   = 443
  }

}

resource "aws_security_group" "dlwb_project_sg" {
  name   = "dlwb_project_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_a.cidr_block, aws_subnet.public_b.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}