variable "cluster_name" {
  description = "Name of the EKS cluster Flagsmith gets deployed to."
  type        = string
}

variable "db_password" {
  description = "RDS instance for Flagsmith root user password."
  type        = string
  sensitive   = true
}
