# https://g.co/gemini/share/9133a4736de2

# Configura el proveedor de Google Cloud
provider "google" {
  project = var.gcp_project_id
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
  for_each = toset(var.gcp_regions)

  name          = "${var.project_name}-subnet-${each.key}"
  ip_cidr_range = var.subnet_cidrs[each.key]
  region        = each.key
  network       = google_compute_network.vpc.id
}