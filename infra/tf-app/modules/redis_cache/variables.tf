variable "resource_group_name" {
  description = "Resource group name for Redis."
  type        = string
}

variable "location" {
  description = "Azure region for Redis."
  type        = string
}

variable "label_prefix" {
  description = "Prefix for naming Azure resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the VNet Redis will use."
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNet Redis will use."
  type        = string
}

variable "subnet_id_test" {
  description = "Subnet ID for Redis test environment."
  type        = string
}

variable "subnet_id_prod" {
  description = "Subnet ID for Redis prod environment."
  type        = string
}

variable "redis_cache_sku" {
  description = "SKU of Redis. Options: Basic, Standard, Premium."
  type        = string
  default     = "Basic"
}

variable "redis_cache_capacity_prod" {
  description = "Redis capacity for prod. Valid values: 1-6 (Basic/Standard) or 1-5 (Premium)."
  type        = string
  default     = "1"
}

variable "redis_cache_capacity_test" {
  description = "Redis capacity for test. Valid values: 0-6 (Basic/Standard) or 1-5 (Premium)."
  type        = string
  default     = "0"
}

variable "redis_cache_family" {
  description = "SKU family. C (Basic/Standard) or P (Premium)."
  type        = string
  default     = "C"
}

variable "request_message" {
  description = "Message for owner when private endpoint connects."
  type        = string
  default     = null
}

variable "redis_public_network_access_enabled" {
  description = "Allow public network access. Defaults to false."
  type        = bool
  default     = false
}

variable "redis_enable_authentication" {
  description = "Enable Redis authentication. Defaults to true."
  type        = bool
  default     = true
}

variable "private_endpoint_prefix" {
  description = "Prefix for Private Endpoint name."
  type        = string
  default     = "pe"
}