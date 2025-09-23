# main.tf

# Configura el proveedor de Google Cloud
provider "google" {
  project = var.gcp_project_id # ⬅️ REEMPLAZA con tu ID de Proyecto
  region  = "us-central1"
}

# 1. Crea una red VPC (Virtual Private Cloud) para alojar los recursos.
resource "google_compute_network" "vpc_personalizada" {
  name                    = "mi-vpc-personalizada"
  auto_create_subnetworks = false # Deshabilitamos la creación automática de subredes para tener más control.
}

# 2. Crea una subred pública dentro de la VPC en la región us-central1.
resource "google_compute_subnetwork" "subnet_publica" {
  name          = "mi-subnet-publica"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_personalizada.id
}

# 3. Crea la máquina virtual (Compute Engine).
resource "google_compute_instance" "vm_publica" {
  name         = "mi-vm-publica"
  # Las 'e2-micro' son máquinas eficientes y de bajo costo, ideales para desarrollo o pruebas.
  machine_type = "e2-micro"
  zone         = "us-central1-a" # Puedes usar cualquier zona dentro de us-central1.

  # Define el disco de arranque con una imagen de Debian 11.
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Conecta la VM a nuestra subred pública.
  network_interface {
    network    = google_compute_network.vpc_personalizada.id
    subnetwork = google_compute_subnetwork.subnet_publica.id

    # Esto asigna una dirección IP externa (pública) efímera a la instancia.
    access_config {}
  }

  # Las etiquetas son útiles para aplicar reglas de firewall.
  tags = ["allow-ssh", "allow-http"]

  # Permite que la VM sea eliminada sin proteger el disco de arranque.
  allow_stopping_for_update = true
}

# 4. Crea una regla de firewall para permitir el tráfico entrante.
resource "google_compute_firewall" "reglas_firewall" {
  name    = "permitir-ssh-http"
  network = google_compute_network.vpc_personalizada.id

  # Permite el tráfico desde cualquier dirección IP de origen.
  source_ranges = ["0.0.0.0/0"]

  # Define los protocolos y puertos permitidos.
  allow {
    protocol = "tcp"
    ports    = ["22", "80"] # Puerto 22 para SSH y 80 para HTTP.
  }

  # Aplica esta regla a todas las VMs con las etiquetas especificadas.
  target_tags = ["allow-ssh", "allow-http"]
}