# --- CLÚSTER DE KUBERNETES (GKE) ---

resource "google_container_cluster" "gke_cluster" {
  for_each = toset(var.gcp_regions)

  name     = "${var.project_name}-cluster-${each.key}"
  location = each.key

  enable_autopilot = true

  deletion_protection = var.deletion_protection_enabled

  # Conecta el clúster a la VPC y a la subred correcta de su región
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet[each.key].id

  depends_on = [google_project_service.container]
}