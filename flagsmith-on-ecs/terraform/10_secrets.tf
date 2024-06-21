data "aws_kms_key" "ssm-kms-key" {
  key_id = var.ssm_kms_key
}

resource "random_password" "rds-password" {
  count            = var.rds_password == "" ? 1 : 0
  length           = 15
  special          = true
  override_special = "#%!&"
}

resource "random_password" "django-secret-key" {
  count            = var.django_secret_key == "" ? 1 : 0
  length           = 25
  special          = true
  override_special = "#%!&"
}

resource "aws_ssm_parameter" "db-password" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_password"
  value  = var.rds_password == "" ? random_password.rds-password[0].result : var.rds_password
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm-kms-key.key_id
}

resource "aws_ssm_parameter" "db-host" {
  name   = "/${var.app_name}/${var.app_environment}/rds_host"
  value  = aws_db_instance.postgres.address
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm-kms-key.key_id
}

resource "aws_ssm_parameter" "django-secret-key" {
  name   = "/${var.app_name}/${var.app_environment}/django_secret_key"
  value  = var.django_secret_key == "" ? random_password.django-secret-key[0].result : var.django_secret_key
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm-kms-key.key_id
}

resource "aws_ssm_parameter" "rds-username" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_username"
  value  = var.rds_username
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm-kms-key.key_id
}

resource "aws_ssm_parameter" "rds-db-name" {
  name   = "/${var.app_name}/${var.app_environment}/rds_db_name"
  value  = var.rds_db_name
  type   = "SecureString"
  key_id = data.aws_kms_key.ssm-kms-key.key_id
}
