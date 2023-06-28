
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.app_name}-postgres-sbg"
  subnet_ids = module.vpc.private_subnets
}


resource "aws_db_instance" "postgres" {
  identifier              = "${var.app_name}-postgres"
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = aws_ssm_parameter.db_password.value
  port                    = "5432"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = var.rds_instance_class
  allocated_storage       = "20"
  storage_encrypted       = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  multi_az                = false
  storage_type            = "gp2"
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
}
