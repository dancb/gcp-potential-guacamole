# --- HABILITACIÓN DE APIS ---

# Habilita la API de Artifact Registry.
# Es necesario para poder crear y gestionar repositorios.
resource "google_project_service" "artifactregistry" {
  project            = var.gcp_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false # Evita deshabilitar la API al destruir los recursos
}

# Habilita la API de Kubernetes Engine.
# Es necesario para poder crear y gestionar clústeres de GKE.
resource "google_project_service" "container" {
  project            = var.gcp_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false # Evita deshabilitar la API al destruir los recursos
}