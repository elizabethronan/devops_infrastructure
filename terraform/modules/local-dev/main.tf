resource "kubernetes_config_map" "local_dev" {
  metadata {
    name      = "local-dev-config"
    namespace = "dev"
  }

  data = {
    ENVIRONMENT         = "local"
    FRONTEND_URL        = "http://localhost:3000"
    PRODUCT_SERVICE_URL = "http://localhost:3001"
    ORDER_SERVICE_URL   = "http://localhost:3002"
    DB_HOST             = "localhost"
    DB_PORT             = "5432"
    DB_NAME             = "ecommerce"
    DB_USER             = "admin"
  }
}

resource "kubernetes_secret" "local_dev" {
  metadata {
    name      = "local-dev-secret"
    namespace = "dev"
  }

  data = {
    DB_PASSWORD = var.db_password
  }
}

resource "kubernetes_config_map" "docker_compose_config" {
  metadata {
    name      = "docker-compose-config"
    namespace = "dev"
  }

  data = {
    COMPOSE_PROJECT_NAME = "ecommerce"
    COMPOSE_FILE         = "docker-compose.yml"
  }
}

resource "kubernetes_network_policy" "local_dev" {
  metadata {
    name      = "local-dev-network-policy"
    namespace = "dev"
  }

  spec {
    pod_selector {
      match_labels = {
        environment = "local"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            environment = "dev"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}