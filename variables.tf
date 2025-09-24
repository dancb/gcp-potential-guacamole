variable "gcp_project_id" {
  type        = string
  description = "El ID único del proyecto de Google Cloud."
  default     = "elite-buttress-472417-g3"
}

variable "project_name" {
  type        = string
  description = "El prefijo para nombrar todos los recursos."
  default     = "potential-guacamole"
}

variable "gcp_regions" {
  type        = list(string)
  description = "Lista de regiones de GCP donde se desplegará la infraestructura."
  default     = ["us-central1", "us-east1"]
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "Mapa de rangos CIDR para las subredes de cada región."
  default = {
    "us-central1" = "10.10.1.0/24",
    "us-east1"    = "10.10.2.0/24",
  }
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Habilita o deshabilita la protección contra eliminación del clúster de GKE."
  default     = false # Cambiado a false para permitir la destrucción
}