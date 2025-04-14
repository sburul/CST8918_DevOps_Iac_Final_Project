CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 5. Create Remix Weather App Module in Terraform Infrastructure

This Terraform configuration defines the infrastructure required to deploy a Remix Weather application on Azure using Azure Kubernetes Service (AKS), Azure Container Registry (ACR), and Redis for caching. Here's a brief overview of the key components:

### Notes:

1. **Azure Container Registry (ACR)**: This will store your Docker images for the Remix Weather app.
2. **Azure Kubernetes Service (AKS)**: There are two clusters defined—**Test** and **Production**.
   - The **Test** cluster has a fixed node pool with 1 node.
   - The **Production** cluster supports autoscaling with a minimum of 1 node and a maximum of 3.
3. **Redis**: There are two Redis caches—one for **Test** and one for **Production**, both with basic configuration and TLS enabled.
4. **Kubernetes Deployment**: A `kubernetes_deployment` resource is created to deploy the `remix-weather` app using the image stored in ACR.
5. **Kubernetes Service**: A LoadBalancer service is created to expose the app externally via port 80, forwarding traffic to the app on port 3000.


## Files Overview

---

### 1. Add  `tf-app/modules/remix_weather_app/main.tf` file

```hcl
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
    name = "remix-weather-app-secrets"
    namespace = "default"
  }

  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL = "redis://:${var.test_redis_key}@${var.test_redis_host}:${var.test_redis_port}?tls=true"
  }
}

# Kubernetes Secret for Production Environment
resource "kubernetes_secret" "remix_weather_app_secret_prod" {
  provider = kubernetes.prod
  
  metadata {
    name = "remix-weather-app-secrets"
    namespace = "default"
  }

  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_URL = "redis://:${var.prod_redis_key}@${var.prod_redis_host}:${var.prod_redis_port}?tls=true"
  }
}

# Kubernetes Deployment for Test Environment
resource "kubernetes_deployment" "remix_weather_app_test" {
  provider = kubernetes.test

  metadata {
    name = "remix-weather-app"
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
                name = kubernetes_secret.remix_weather_app_secret_test.metadata[0].name
                key  = "WEATHER_API_KEY"
              }
            }
          }

          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.remix_weather_app_secret_test.metadata[0].name
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
    name = "remix-weather-app"
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
    name = "remix-weather-app"
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
    name = "remix-weather-app"
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

```

---

### 2. Add  `tf-app/modules/remix_weather_app/variables.tf` file

```hcl
# Resource Group Variables
variable "label_prefix" {
  type        = string
  description = "A short prefix used to consistently name and identify Azure resources related to the AKS deployment. Helps with resource organization and filtering."
}

variable "location" {
  type        = string
  description = "The Azure region where the AKS clusters will be deployed (e.g., canadacentral, eastus). This determines the physical location of the infrastructure."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing Azure Resource Group in which the AKS clusters and associated resources will be created."
}

# AKS Cluster Principal IDs for ACR Access
variable "test_cluster_principal_id" {
  description = "The principal ID of the managed identity for the test AKS cluster, used for authentication to Azure resources such as ACR."
  type        = string
}

variable "prod_cluster_principal_id" {
  description = "The principal ID of the managed identity for the production AKS cluster, used for authentication to Azure resources such as ACR."
  type        = string
}

# AKS Cluster Connection Details - Test Environment
variable "test_cluster_host" {
  description = "The Kubernetes API server host URL for the test AKS cluster."
  type        = string
}

variable "test_client_certificate" {
  description = "The base64 encoded client certificate for authenticating to the test Kubernetes cluster."
  type        = string
  sensitive   = true
}

variable "test_client_key" {
  description = "The base64 encoded private key for authenticating to the test Kubernetes cluster."
  type        = string
  sensitive   = true
}

variable "test_cluster_ca_certificate" {
  description = "The base64 encoded public CA certificate for the test Kubernetes cluster, used to establish trust for secure connections."
  type        = string
  sensitive   = true
}

# AKS Cluster Connection Details - Production Environment
variable "prod_cluster_host" {
  description = "The Kubernetes API server host URL for the production AKS cluster."
  type        = string
}

variable "prod_client_certificate" {
  description = "The base64 encoded client certificate for authenticating to the production Kubernetes cluster."
  type        = string
  sensitive   = true
}

variable "prod_client_key" {
  description = "The base64 encoded private key for authenticating to the production Kubernetes cluster."
  type        = string
  sensitive   = true
}

variable "prod_cluster_ca_certificate" {
  description = "The base64 encoded public CA certificate for the production Kubernetes cluster, used to establish trust for secure connections."
  type        = string
  sensitive   = true
}

# Redis Cache Connection Details - Test Environment
variable "test_redis_host" {
  description = "The hostname of the Redis Cache instance used in the test environment."
  type        = string
}

variable "test_redis_port" {
  description = "The port on which the Redis Cache instance in the test environment is listening."
  type        = number
}

variable "test_redis_key" {
  description = "The primary access key for authenticating to the Redis Cache instance in the test environment."
  type        = string
  sensitive   = true
}

# Redis Cache Connection Details - Production Environment
variable "prod_redis_host" {
  description = "The hostname of the Redis Cache instance used in the production environment."
  type        = string
}

variable "prod_redis_port" {
  description = "The port on which the Redis Cache instance in the production environment is listening."
  type        = number
}

variable "prod_redis_key" {
  description = "The primary access key for authenticating to the Redis Cache instance in the production environment."
  type        = string
  sensitive   = true
}

# Weather API Configuration
variable "weather_api_key" {
  description = "API key required to authenticate with the OpenWeather API."
  type        = string
  sensitive   = true
}

# Container Configuration for Deployment
variable "image_tag" {
  description = "The tag associated with the container image to be used for deployment (default is 'latest')."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port that the container exposes to interact with external services."
  type        = number
  default     = 80
}

```

---

### 3. Add  `tf-app/modules/remix_weather_app/outputs.tf` file

```hcl

# Outputs Container Registry
output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry (ACR)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username for authenticating with Azure Container Registry (ACR)"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Admin password for ACR (sensitive data)"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# Test Environment Outputs

output "test_deployment_name" {
  description = "Name of the Kubernetes deployment in the test environment"
  value       = kubernetes_deployment.remix_weather_app_test.metadata[0].name
}

output "test_service_name" {
  description = "Name of the Kubernetes service in the test environment"
  value       = kubernetes_service.remix_weather_app_test.metadata[0].name
}

output "test_service_endpoint" {
  description = "Internal IP address of the Kubernetes service in the test environment"
  value       = kubernetes_service.remix_weather_app_test.spec[0].cluster_ip
}

# Production Environment Outputs

output "prod_deployment_name" {
  description = "Name of the Kubernetes deployment in the production environment"
  value       = kubernetes_deployment.remix_weather_app_prod.metadata[0].name
}

output "prod_service_name" {
  description = "Name of the Kubernetes service in the production environment"
  value       = kubernetes_service.remix_weather_app_prod.metadata[0].name
}

output "prod_service_endpoint" {
  description = "External IP address of the Kubernetes service in the production environment"
  value       = kubernetes_service.remix_weather_app_prod.status[0].load_balancer[0].ingress[0].ip
}

```

---

### 4. Update `tf-app/main.tf` to Include the AKS Module

```hcl
# Remix Weather App Module
module "remix_weather_app" {
  source              = "./modules/remix_weather_app"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  # AKS cluster principal IDs for ACR access
  test_cluster_principal_id = module.aks.test_cluster_principal_id
  prod_cluster_principal_id = module.aks.prod_cluster_principal_id

  # AKS cluster connection details from AKS module outputs
  test_cluster_host           = module.aks.test_kube_config_host
  test_client_certificate     = module.aks.test_kube_config_client_certificate
  test_client_key             = module.aks.test_kube_config_client_key
  test_cluster_ca_certificate = module.aks.test_kube_config_cluster_ca_certificate

  prod_cluster_host           = module.aks.prod_kube_config_host
  prod_client_certificate     = module.aks.prod_kube_config_client_certificate
  prod_client_key             = module.aks.prod_kube_config_client_key
  prod_cluster_ca_certificate = module.aks.prod_kube_config_cluster_ca_certificate

    # Redis connection info from Redis module outputs
  test_redis_host = module.redis.test_redis_host
  test_redis_port = module.redis.test_redis_ssl_port
  test_redis_key  = module.redis.test_redis_primary_key
  prod_redis_host = module.redis.prod_redis_host
  prod_redis_port = module.redis.prod_redis_ssl_port
  prod_redis_key  = module.redis.prod_redis_primary_key

  # Weather API key - will be populated by GitHub Action or from tfvars
  weather_api_key = var.weather_api_key

  # Container image settings
  image_tag      = var.image_tag
  container_port = 80
}
```

---




