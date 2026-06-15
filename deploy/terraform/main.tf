terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Static public IP (point your DNS A record here)
resource "google_compute_address" "boostcast_mmart" {
  name   = "boostcast-mmart-ip"
  region = var.region
}

# Firewall: web UI (HTTP/HTTPS) + SFTP uploads
resource "google_compute_firewall" "web" {
  name          = "boostcast-mmart-web"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["boostcast-mmart"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2022"]
  }
}

# Firewall: station streaming / relay ports
resource "google_compute_firewall" "streams" {
  name          = "boostcast-mmart-streams"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["boostcast-mmart"]

  allow {
    protocol = "tcp"
    ports    = ["8000-8500"]
  }
}

resource "google_compute_instance" "boostcast_mmart" {
  name         = "boostcast-mmart"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["boostcast-mmart"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.boostcast_mmart.address
    }
  }

  # Installs Docker and launches BoostCast on first boot.
  metadata_startup_script = templatefile("${path.module}/startup-script.sh.tftpl", {
    image             = var.image
    domain            = var.domain
    letsencrypt_email = var.letsencrypt_email
    mysql_password    = var.mysql_password
  })
}
