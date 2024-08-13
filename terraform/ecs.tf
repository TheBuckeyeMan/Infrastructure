resource "aws_ecs_service" "ecs_service" {
    name = "ecs_service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_tasl.arn
    desired_count = 1
    launch_type = "FARGATE"
    network_configuration {
      subnets = [aws_subnet.subnet.id]
      security_groups = [aws_security_group.security_group.id]
    }
}