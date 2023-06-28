variable "region" {
  type        = string
  description = "The AWS region to create resources in."
}

variable "app_environment" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type = string
}


# VPC

variable "vpc_cidr" {
  type        = string
  description = "CDIR of VPC"
  default     = "10.0.0.0/16"
}

# load balancer

variable "health_check_path" {
  type        = string
  description = "Health check path for the default target group"
  default     = "/health/"
}

# ECS Fargate

variable "docker_image_url" {
  type        = string
  description = "Docker image to run in the ECS cluster"
  default     = "flagsmith/flagsmith:latest"
}

variable "app_count" {
  type        = number
  description = "Number of Docker containers to run"
  default     = 2
}

# FIXME
variable "allowed_hosts" {
  type        = string
  description = "Domain name for allowed hosts"
}


# logs

variable "log_retention_in_days" {
  type    = number
  default = 7
}

variable "settings_module" {
  type        = string
  description = "Application settings"
  default     = "app.settings.production"
}

# RDS
variable "ssm_kms_key" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS key to store encrypted password in AWS SSM Parameter store service"
}

variable "rds_db_name" {
  type        = string
  description = "RDS database name"
  default     = "flagsmithdb"
}

variable "rds_username" {
  type        = string
  description = "RDS database username"
  default     = "flagsmithdbuser"
}

variable "rds_password" {
  type        = string
  description = "RDS database password"
  default     = ""
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance type"
  default     = "db.t3.micro"
}

# domain

variable "route53_hosted_zone" {
  type = string
}

# Django

variable "django_secret_key" {
  type        = string
  description = "Django env. variable DJANGO_SECRET_KEY"
  default     = ""
}

# Fargate's  compute capacity profile

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}