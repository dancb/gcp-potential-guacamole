# variables.tf
variable "gcp_project_id" {
  type        = string
  description = "El ID del proyecto de Google Cloud a utilizar."
  default     = "elite-buttress-472417-g3"
}