resource "aws_ecr_repository" "containers_for_ecs"{
    name = "Youtube_Containers"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
      scan_on_push = true
    }
}