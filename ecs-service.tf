resource "aws_ecs_cluster" "lesson7" {
  name = "lesson7"
}

resource "aws_ecs_task_definition" "lesson7" {
  family                   = "lesson7"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "739133790707.dkr.ecr.eu-cetntral-1.amazonaws.com/mynginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.nginx.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }

    }
  ])
}


resource "aws_ecs_service" "lesson7" {
  name            = "lesson7"
  cluster        = aws_ecs_cluster.lesson7.id
  task_definition = aws_ecs_task_definition.lesson7.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets            = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

    load_balancer {
        target_group_arn = aws_lb_target_group.main.arn
        container_name   = "web"
        container_port   = 80
    }
}