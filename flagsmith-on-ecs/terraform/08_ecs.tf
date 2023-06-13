resource "aws_ecs_cluster" "flagsmith" {
  name = local.ecs_cluster_name
}
