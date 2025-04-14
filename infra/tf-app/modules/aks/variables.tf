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

variable "test_subnet_id" {
  type        = string
  description = "The ID of the subnet within a Virtual Network (VNet) that will be used for deploying the test AKS cluster. This subnet must exist prior to deployment."
}

variable "prod_subnet_id" {
  type        = string
  description = "The ID of the subnet within a Virtual Network (VNet) used by the production AKS cluster. It should be configured to support autoscaling and production workloads."
}
