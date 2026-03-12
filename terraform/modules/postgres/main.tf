resource "kubernetes_config_map" "postgres" {
    metadata {
        name = "postgres-config"
        namespace = "dev"
    }

    data = {
        POSTGRES_DB = "ecommerce"
        POSTGRES_USER = "admin"
    }
}

resource "kubernetes_secret" "postgres" {
    metadata {
        name = "postgres-secret"
        namespace = "dev"
    }
    data = {
        POSTGRES_PASSWORD = var.db_password
    }
}

resource "kubernetes_persistent_volume" "postgres" {
    metadata {
        name = "postgres-pv"
    }

    spec {
        capacity = {
            storage = "1Gi"
        }
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "standard"

        persistent_volume_source {
            host_path {
                path = "/mnt/data/postgres"
            }
        }
    }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
    metadata {
        name = "postgres-pvc"
        namespace = "dev"
    }

    spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
            requests = {
                storage = "1Gi"
            }
        }
    }
}

resource "kubernetes_deployment" "postgres" {
    metadata {
        name = "database"
        namespace = "dev"
        labels = {
            app = "database"
        }
    }

    spec {
        replicas = 1
        
        selector {
            match_labels = {
                app = "database"
            }
        }

        template {
            metadata {
                labels = {
                    app = "database"
                }
            }
            spec {
                container {
                    name = "database"
                    image = "eronan22/database:latest"

                    port {
                        container_port = 5432
                    }
                    env_from {
                        config_map_ref {
                            name = kubernetes_config_map.postgres.metadata[0].name
                        }
                    }

                    env {
                        name = "POSTGRES_PASSWORD"
                        value_from {
                            secret_key_ref {
                                name = kubernetes_secret.postgres.metadata[0].name
                                key = "POSTGRES_PASSWORD"
                            }
                        }
                    }
                    volume_mount {
                        name = "postgres-storage"
                        mount_path = "/var/lib/postgresql/data"
                    }
                }
        
                volume {
                    name = "postgres-storage"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.postgres.metadata[0].name
                    }
                }
            }
        }
    }
}


resource "kubernetes_service" "postgres" {
    metadata {
        name = "database"
        namespace = "dev"
    }
    spec {
        selector = {
            app = "database"
        }

        port {
            port = 5432
            target_port = 5432
        }
    }
}