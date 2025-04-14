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
