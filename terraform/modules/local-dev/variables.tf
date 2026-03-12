variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "dev"
}

variable "frontend_port" {
  description = "Frontend service port"
  type        = number
  default     = 3000
}

variable "product_service_port" {
  description = "Product service port"
  type        = number
  default     = 3001
}

variable "order_service_port" {
  description = "Order service port"
  type        = number
  default     = 3002
}