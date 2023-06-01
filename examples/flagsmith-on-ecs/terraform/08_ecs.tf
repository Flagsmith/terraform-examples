resource "aws_ecs_cluster" "production" {
  name = local.ecs_cluster_name
}
