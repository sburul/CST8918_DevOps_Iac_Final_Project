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

# Remix Weather API key for GitHub Action
variable "weather_api_key" {
  type        = string
  default     = "c83ad984094f07b96a2d315fa30505ea"
  description = "API key for OpenWeather API"
  sensitive   = true
}
