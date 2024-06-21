resource "aws_iam_role" "ecs-host-role" {
  name               = "${var.app_name}-ecs-host-role-${var.app_environment}"
  assume_role_policy = file("policies/ecs-task-role.json")
}

resource "aws_iam_role_policy" "ecs-host-role-policy" {
  name = "${var.app_name}-ecs-host-role-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        "Resource" : "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameters"],
        Resource = ["arn:aws:ssm:${var.region}:${local.AWS_ACCOUNT_ID}:parameter/${var.app_name}/*"]
      }
    ]
    }
  )
  role = aws_iam_role.ecs-host-role.id
}

resource "aws_iam_role" "ecs-task" {
  name               = "${var.app_name}-ecs-task"
  assume_role_policy = file("policies/ecs-task-role.json")
}

resource "aws_iam_role_policy" "ecs-task" {
  name = "${var.app_name}-ecs-task-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameters"],
        Resource = ["arn:aws:ssm:${var.region}:${local.AWS_ACCOUNT_ID}:parameter/${var.app_name}/*"]
      }
    ]
  })
  role = aws_iam_role.ecs-task.id
}
