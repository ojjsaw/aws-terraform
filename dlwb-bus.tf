resource "aws_ecs_task_definition" "dlwb_bus" {
  family                   = "dlwb-bus"
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
      name      = "bus"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/applications.services.devcloud.workbench-bus:runtime"
      essential = true
      command   = ["-js", "-D"]
      portMappings = [
        {
          containerPort = 4222
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/dlwb/bus",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "dlwb_bus" {
  name            = "dlwb-bus"
  cluster         = aws_ecs_cluster.dlwb_fargate.id
  task_definition = aws_ecs_task_definition.dlwb_bus.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role.fargate_execution, aws_service_discovery_service.bus]

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.dlwb_bus_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bus_nlb_tg.arn
    container_name   = "bus"
    container_port   = 4222
  }

  service_registries {
    registry_arn = aws_service_discovery_service.bus.arn
  }

}

resource "aws_security_group" "dlwb_bus_sg" {
  name   = "dlwb_bus_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 4222
    to_port     = 4222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = [aws_subnet.public_a.cidr_block, aws_subnet.public_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.tags
}