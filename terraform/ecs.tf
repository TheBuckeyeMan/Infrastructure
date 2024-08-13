# Declare the ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

# Declare the ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                = "ecs_task"
  container_definitions = jsonencode([
    {
      name  = "placeholder-container"
      image = "hello-world-placeholder"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
}

resource "aws_ecs_service" "ecs_service" {
    name = "ecs_service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_task.arn
    desired_count = 1
    launch_type = "FARGATE"
    network_configuration {
      subnets = [aws_subnet.subnet.id]
      security_groups = [aws_security_group.security_group.id]
    }
}