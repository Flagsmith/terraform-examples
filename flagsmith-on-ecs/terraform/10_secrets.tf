data "aws_kms_key" "ssm_kms_key" {
  key_id = var.ssm_kms_key
}

resource "random_password" "rds_password" {
  count            = var.rds_password == "" ? 1 : 0
  length           = 15
  special          = true
  override_special = "#%!&"
}

resource "random_password" "django_secret_key" {
  count            = var.django_secret_key == "" ? 1 : 0
  length           = 25
  special          = true
  override_special = "#%!&"
}

resource "aws_ssm_parameter" "db_password" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_password"
  value  = var.rds_password == "" ? random_password.rds_password[0].result : var.rds_password
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm_kms_key.key_id
}

resource "aws_ssm_parameter" "db_host" {
  name   = "/${var.app_name}/${var.app_environment}/rds_host"
  value  = aws_db_instance.postgres.address
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm_kms_key.key_id
}

resource "aws_ssm_parameter" "django_secret_key" {
  name   = "/${var.app_name}/${var.app_environment}/django_secret_key"
  value  = var.django_secret_key == "" ? random_password.django_secret_key[0].result : var.django_secret_key
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm_kms_key.key_id
}

resource "aws_ssm_parameter" "rds_username" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_username"
  value  = var.rds_username
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm_kms_key.key_id
}

resource "aws_ssm_parameter" "rds_db_name" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_name"
  value  = var.rds_db_name
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm_kms_key.key_id
}
