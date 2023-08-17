resource "aws_ecs_task_definition" "dlwb_client" {
  family                   = "dlwb-client"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_execution.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  # 1 vCPU
  cpu = 1024
  # 2 GB
  memory = 2048
  container_definitions = jsonencode([
    {
      name      = "client"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/applications.services.devcloud.workbench-client:runtime"
      essential = true
      command = ["serve", "-s", "build", "-p", "3000"]
      portMappings = [
        {
          containerPort = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/dlwb/client",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "dlwb_client" {
  name            = "dlwb-client"
  cluster         = aws_ecs_cluster.dlwb_fargate.id
  task_definition = aws_ecs_task_definition.dlwb_client.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role.fargate_execution]

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.dlwb_client_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.client_alb_tg.arn
    container_name   = "client"
    container_port   = 3000
  }

}

resource "aws_security_group" "dlwb_client_sg" {
  name   = "dlwb_client_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
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