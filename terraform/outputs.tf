# Minikube cluster connection details
output "cluster_context" {
  description = "Kubernetes cluster context"
  value       = "minikube"
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = "https://127.0.0.1:8443"
}

output "current_namespace" {
  description = "Current active namespace based on workspace"
  value       = terraform.workspace
}

# Docker registry information
output "docker_registry" {
  description = "Docker Hub registry URL"
  value       = "registry-1.docker.io"
}

output "docker_registry_username" {
  description = "Docker Hub username"
  value       = "eronan22"
}

output "frontend_image" {
  description = "Frontend Docker image"
  value       = "eronan22/ecommerce-frontend:latest"
}

output "product_service_image" {
  description = "Product service Docker image"
  value       = "eronan22/product-service:latest"
}

output "order_service_image" {
  description = "Order service Docker image"
  value       = "eronan22/order-service:latest"
}

output "database_image" {
  description = "Database Docker image"
  value       = "eronan22/database:latest"
}

# Service URLs and ports
output "frontend_url" {
  description = "Frontend service URL"
  value       = "http://localhost:3000"
}

output "product_service_url" {
  description = "Product service URL"
  value       = "http://localhost:3001"
}

output "order_service_url" {
  description = "Order service URL"
  value       = "http://localhost:3002"
}

output "database_url" {
  description = "Database connection URL"
  value       = "postgresql://admin@localhost:5432/ecommerce"
  sensitive   = true
}

# Jenkins pipeline values
output "jenkins_url" {
  description = "Jenkins server URL"
  value       = "http://localhost:8080"
}

output "jenkins_kubernetes_namespace" {
  description = "Namespace Jenkins deploys to"
  value       = module.minikube.namespace
}

output "postgres_service_name" {
  description = "PostgreSQL service name for pipeline use"
  value       = module.postgres.postgres_service_name
}

output "postgres_namespace" {
  description = "PostgreSQL namespace for pipeline use"
  value       = module.postgres.postgres_namespace
}