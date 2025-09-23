# --- CLÚSTER DE KUBERNETES (GKE) ---

resource "google_container_cluster" "gke_cluster" {
  name     = "${var.project_name}-cluster"
  location = "us-central1"

  enable_autopilot = true
}