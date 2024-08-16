# Declare the ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

# Declare the ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "placeholder-container",
      image = "${aws_ecr_repository.containers_for_ecs.repository_url}:containerforecs",
      cpu   = 256,
      memory = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "ecs_task"
  }
}


resource "aws_ecs_service" "ecs_service" {
  name            = "ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet.id]
    security_groups   = [aws_security_group.security_group.id]
    assign_public_ip  = true
  }

  tags = {
    Name = "ecs_service"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ecs_task_execution_role"
  }
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}