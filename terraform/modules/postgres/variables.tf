variable "db_password" {
    description = "PostgreSQL password"
    type = string
    sensitive = true
}

variable "namespace" {
    description = "Kubernetes namespace"
    type = string
    default = "dev"
}