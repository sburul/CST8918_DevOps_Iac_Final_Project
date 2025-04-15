terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0"
    }
  }
}
 
# ACR Configs
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.label_prefix, "-", "")}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}
 
# We give AKS the necessary permissions to take images from ACR
resource "azurerm_role_assignment" "acr_pull_test" {
  principal_id                     = var.test_cluster_principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
 
resource "azurerm_role_assignment" "acr_pull_prod" {
  principal_id                     = var.prod_cluster_principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
 
# Kubernetes for Test Environment
provider "kubernetes" {
  alias                  = "test"
  host                   = var.test_cluster_host
  client_certificate     = var.test_client_certificate
  client_key             = var.test_client_key
  cluster_ca_certificate = var.test_cluster_ca_certificate
}
 
# Kubernetes Config for
provider "kubernetes" {
  alias                  = "prod"
  host                   = var.prod_cluster_host
  client_certificate     = var.prod_client_certificate
  client_key             = var.prod_client_key
  cluster_ca_certificate = var.prod_cluster_ca_certificate
}
 
# Kubernetes Secret for Test Environment
resource "kubernetes_secret" "remix_weather_app_secret_test" {
  provider = kubernetes.test
 
  metadata {
    name      = "remix-weather-app-secrets"
    namespace = "default"
  }
 
  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL       = "redis://:${var.test_redis_key}@${var.test_redis_host}:${var.test_redis_port}?tls=true"
  }
}
 
# Kubernetes Secret for Production Environment
resource "kubernetes_secret" "remix_weather_app_secret_prod" {
  provider = kubernetes.prod
 
  metadata {
    name      = "remix-weather-app-secrets"
    namespace = "default"
  }
 
  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL       = "redis://:${var.prod_redis_key}@${var.prod_redis_host}:${var.prod_redis_port}?tls=true"
  }
}
 
# Kubernetes Deployment for Test Environment
resource "kubernetes_deployment" "remix_weather_app_test" {
  provider = kubernetes.test
 
  metadata {
    name      = "remix-weather-app"
    namespace = "default"
    labels = {
      app = "remix-weather-app"
    }
  }
 
  spec {
    replicas = 1
 
    selector {
      match_labels = {
        app = "remix-weather-app"
      }
    }
 
    template {
      metadata {
        labels = {
          app = "remix-weather-app"
        }
      }
 
      spec {
        container {
          image = "${azurerm_container_registry.acr.login_server}/remix-weather-app:${var.image_tag}"
          name  = "remix-weather-app"
 
          port {
            container_port = var.container_port
          }
 
          env {
            name = "WEATHER_API_KEY"
            value_from {
              secret_key_ref {
                name = "remix-weather-app-secrets"
                key  = "WEATHER_API_KEY"
              }
            }
          }
 
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = "remix-weather-app-secrets"
                key  = "REDIS_URL"
              }
            }
          }
 
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
 
# Kubernetes Service for Test Environment
resource "kubernetes_service" "remix_weather_app_test" {
  provider = kubernetes.test
 
  metadata {
    name      = "remix-weather-app"
    namespace = "default"
  }
 
  spec {
    selector = {
      app = "remix-weather-app"
    }
 
    port {
      port        = 80
      target_port = 3000
    }
 
    type = "ClusterIP"
  }
}
 
# Kubernetes Deployment for Production Environment
resource "kubernetes_deployment" "remix_weather_app_prod" {
  provider = kubernetes.prod
 
  metadata {
    name      = "remix-weather-app"
    namespace = "default"
    labels = {
      app = "remix-weather-app"
    }
  }
 
  spec {
    replicas = 1
 
    selector {
      match_labels = {
        app = "remix-weather-app"
      }
    }
 
    template {
      metadata {
        labels = {
          app = "remix-weather-app"
        }
      }
 
      spec {
        container {
          image = "${azurerm_container_registry.acr.login_server}/remix-weather-app:${var.image_tag}"
          name  = "remix-weather-app"
 
          port {
            container_port = var.container_port
          }
 
          env {
            name = "WEATHER_API_KEY"
            value_from {
              secret_key_ref {
                name = "remix-weather-app-secrets"
                key  = "WEATHER_API_KEY"
              }
            }
          }
 
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = "remix-weather-app-secrets"
                key  = "REDIS_URL"
              }
            }
          }
 
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
 
# Kubernetes Service for Production Environment
resource "kubernetes_service" "remix_weather_app_prod" {
  provider = kubernetes.prod
 
  metadata {
    name      = "remix-weather-app"
    namespace = "default"
  }
 
  spec {
    selector = {
      app = "remix-weather-app"
    }
 
    port {
      port        = 80
      target_port = 3000
    }
 
    type = "LoadBalancer"
  }
}
 
 