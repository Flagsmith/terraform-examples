resource "aws_iam_role" "ecs_host_role" {
  name               = "${var.app_name}-ecs-host-role-${var.app_environment}"
  assume_role_policy = file("policies/ecs-host-role.json")
}

resource "aws_iam_role_policy" "ecs-host-role-policy" {
  name   = "${var.app_name}-ecs-host-role-policy"
  policy = file("policies/ecs-host-role-policy.json")
  role   = aws_iam_role.ecs_host_role.id
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.app_name}-ecs-task"
  assume_role_policy = file("policies/ecs-host-role.json")
}

resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.app_name}-ecs-task-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "ssm:GetParameters"],
        Resource = ["arn:aws:ssm:${var.region}:${local.AWS_ACCOUNT_ID}:parameter/${var.app_name}/"]
      },
      # used for ECS Exec
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      }
    ]
  })
  role = aws_iam_role.ecs_task.id
}
