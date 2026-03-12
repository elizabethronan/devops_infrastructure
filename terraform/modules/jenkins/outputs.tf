output "jenkins_namespace" {
    value = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_name" {
    value = kubernetes_service.jenkins.metadata[0].name
}

output "jenkins_node_port" {
    value = 32000
}