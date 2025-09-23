# https://g.co/gemini/share/9133a4736de2

# Configura el proveedor de Google Cloud
provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

# Data source para obtener información del proyecto actual
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# --- RED Y FIREWALL ---

resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}