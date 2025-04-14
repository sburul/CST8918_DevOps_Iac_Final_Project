variable "label_prefix" {
  type        = string
  description = "A short prefix used to consistently name and identify Azure resources related to the Redis Cache deployment. Helps with resource organization and filtering."
}

variable "location" {
  type        = string
  description = "The Azure region where the Redis Cache instances will be deployed (e.g., canadacentral, eastus). This determines the physical location of the infrastructure."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing Azure Resource Group in which the Redis Cache instances will be created."
}