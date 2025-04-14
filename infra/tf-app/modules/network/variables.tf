# Prefix used to standardize naming across all Azure resources
variable "label_prefix" {
  description = "A short, descriptive prefix used to consistently name all resources created by this module."
  type        = string
}

# Azure region where all resources will be deployed
variable "region" {
  description = "The Azure region where the resources will be provisioned. Default is 'Canada Central'."
  type        = string
  default     = "canadacentral"
}

# Name of the Azure resource group that will contain the resources
variable "resource_group_name" {
  description = "The name of the existing Azure Resource Group in which all resources will be deployed."
  type        = string
}
