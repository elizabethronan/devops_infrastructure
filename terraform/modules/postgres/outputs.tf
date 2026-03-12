output "postgres_service_name" {
    value = kubernetes_service.postgres.metadata[0].name
}

output "postgres_namespace" {
    value = kubernetes_secret.postgres.metadata[0].namespace
}