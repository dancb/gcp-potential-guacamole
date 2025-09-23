# --- ARTIFACT REGISTRY ---

# Crea un repositorio de Artifact Registry para almacenar imágenes de Docker.
resource "google_artifact_registry_repository" "docker_repo" {
  location      = "us-central1"
  repository_id = "${var.project_name}-repo"
  description   = "Repositorio de Docker para la aplicación."
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# Otorga permisos al Service Account por defecto de Compute Engine para leer
# imágenes del repositorio. GKE Autopilot utiliza esta cuenta por defecto
# para extraer imágenes.
resource "google_artifact_registry_repository_iam_member" "gke_pull_access" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"

  # Data source para obtener el email del Service Account por defecto de Compute Engine.
  # {project_number}-compute@developer.gserviceaccount.com
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}