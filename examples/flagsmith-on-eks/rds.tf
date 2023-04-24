data "aws_vpc" "cluster" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds"
  subnet_ids = data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "flagsmith_rds"
  vpc_id = data.aws_vpc.cluster.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flagsmith_rds"
  }
}

resource "aws_db_parameter_group" "flagsmith_db" {
  name   = "flagsmith"
  family = "postgres11"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "random_password" "flagsmith_db_password" {
  length  = 32
  special = true
}

resource "aws_db_instance" "flagsmith_db" {
  identifier             = "flagsmith-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  db_name                = "flagsmith"
  engine                 = "postgres"
  engine_version         = "12.14"
  username               = "flagsmith"
  password               = random_password.flagsmith_db_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.flagsmith_db.name
  skip_final_snapshot    = true
}
