variable "environment" {
    description = "Deployment environment"
    type = string
    default = "dev"
}

variable "db_password" {
    description = "PostgreSQL password"
    type = string
    sensitive = true
}

variable "replicas" {
  description = "Number of replicas per service"
  type        = number
  default     = 1
}