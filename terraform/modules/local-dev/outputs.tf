output "local_dev_config_name" {
  value = kubernetes_config_map.local_dev.metadata[0].name
}

output "local_dev_secret_name" {
  value = kubernetes_secret.local_dev.metadata[0].name
}

output "environment" {
  value = "local"
}