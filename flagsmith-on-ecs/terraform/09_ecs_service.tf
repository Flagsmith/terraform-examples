resource "aws_ecs_task_definition" "app" {
  family = "flagsmith"
  container_definitions = templatefile("templates/flagsmith.json", {
    container_name   = var.app_name
    docker_image_url = var.docker_image_url
    region           = var.region

    allowed_hosts   = var.allowed_hosts
    settings_module = var.settings_module
    AWS_ACCOUNT_ID  = local.AWS_ACCOUNT_ID
    app_environment = var.app_environment
    app_name        = var.app_name
  })
  depends_on               = [aws_db_instance.postgres]
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = aws_iam_role.ecs-task.arn
  execution_role_arn       = aws_iam_role.ecs-host-role.arn

}

resource "aws_ecs_service" "flagsmith-svc" {
  name            = "${local.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.flagsmith.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  ## prevent race condition - iam
  depends_on = [aws_alb_listener.ecs-alb-http-listener, aws_iam_role_policy.ecs-task]

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = var.app_name
    container_port   = 8000
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 0
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
    subnets          = module.vpc.private_subnets
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
