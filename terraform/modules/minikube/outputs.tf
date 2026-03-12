output "namespace" {
  value = kubernetes_namespace.environment.metadata[0].name
}