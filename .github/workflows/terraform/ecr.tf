# resource "aws_ecr_repository" "containers_for_ecs"{
#     name = "containers_for_ecs"
#     image_tag_mutability = "MUTABLE"
#     image_scanning_configuration {
#       scan_on_push = true
#     }
# }