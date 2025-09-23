# Configura el proveedor de Google Cloud
provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
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

resource "google_compute_firewall" "firewall" {
  name    = "${var.project_name}-allow-ssh-http"
  network = google_compute_network.vpc.id

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
  target_tags = ["http-server", "ssh-server"]
}


# --- MÁQUINA VIRTUAL (Compute Engine) ---

resource "google_compute_instance" "vm" {
  name         = "${var.project_name}-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  tags = ["http-server", "ssh-server"]
}