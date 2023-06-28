locals {
  ecs_cluster_name = "${var.app_name}-${var.app_environment}-cluster"
  AWS_ACCOUNT_ID   = data.aws_caller_identity.current.account_id
}