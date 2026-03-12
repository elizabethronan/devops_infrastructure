resource "kubernetes_namespace" "environment" {
  metadata {
    name = var.environment
    labels = {
      environment = var.environment
    }
  }
}