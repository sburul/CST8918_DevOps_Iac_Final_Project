# Define config variables
variable "labelPrefix" {
  type        = string
  default     = "cst8918-final-project-group-2"
  description = "Prefix label for resources"

}

# Region
variable "region" {
  default = "canadacentral"
}