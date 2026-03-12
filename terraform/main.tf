terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"

  backend "local" {
    path          = "terraform.tfstate"
    workspace_dir = "workspaces"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

locals {
  environment = terraform.workspace
}

module "minikube" {
  source      = "./modules/minikube"
  environment = local.environment
}

module "postgres" {
  source      = "./modules/postgres"
  db_password = var.db_password
  namespace   = local.environment
  depends_on  = [module.minikube]
}

module "jenkins" {
  source     = "./modules/jenkins"
  depends_on = [module.minikube]
}

module "local_dev" {
  source      = "./modules/local-dev"
  db_password = var.db_password
  namespace   = local.environment
  depends_on  = [module.minikube]
}

