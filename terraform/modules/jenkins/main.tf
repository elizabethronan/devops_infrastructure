resource "kubernetes_namespace" "jenkins" {
    metadata {
        name = "jenkins"
        labels = {
            environment = "ci"
        }
    }
}

resource "kubernetes_persistent_volume" "jenkins" {
    metadata {
      name = "jenkins-pv"
    }

    spec {
        capacity = {
            storage = "2Gi"
        }
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "standard"

        persistent_volume_source {
            host_path {
                path = "/mnt/data/jenkins"
            }
        }
    }
}

resource "kubernetes_persistent_volume_claim" "jenkins" {
    metadata {
        name = "jenkins-pvc"
        namespace = kubernetes_namespace.jenkins.metadata[0].name
    }

    spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
            requests = {
                storage = "2Gi"
            }
        }
    }
}

resource "kubernetes_deployment" "jenkins" {
    metadata {
      name = "jenkins"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
      labels = {
        app = "jenkins"
      }
    }

    spec {
        replicas = 1

        selector {
          match_labels = {
            app = "jenkins"
          }
        }

        template {
            metadata {
              labels = {
                app = "jenkins"
              }
            }
            
            spec {
                container {
                    name = "jenkins"
                    image = "jenkins/jenkins:lts"

                    port {
                        container_port = 8080
                        name = "http"
                    }

                    port {
                      container_port = 50000
                      name = "agent"
                    }
                    volume_mount {
                      name = "jenkins-storage"
                      mount_path = "/var/jenkins_home"
                    }

                    resources {
                        requests = {
                          memory = "512Mi"
                          cpu = "500m"
                        }
                        limits = {
                            memory = "1Gi"
                            cpu = "1000m"
                        }
                    }
                }

                volume {
                    name = "jenkins-storage"
                    persistent_volume_claim {
                      claim_name = kubernetes_persistent_volume_claim.jenkins.metadata[0].name
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "jenkins" {
    metadata {
      name = "jenkins"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    }

    spec {
        selector = {
          app = "jenkins"
        }

        type = "NodePort"

        port {
            name = "http"
            port = 8080
            target_port = 8080
            node_port = 32000
        }
        port {
            name = "agent"
            port = 50000
            target_port = 50000
        }
    }
}