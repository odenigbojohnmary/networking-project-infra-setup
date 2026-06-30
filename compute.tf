
# ---------------------------------------------------------------------------
# Network (uses default VPC; override with var.network/var.subnetwork if needed)
# ---------------------------------------------------------------------------

resource "google_compute_firewall" "allow_http_https_ssh" {
  name    = "${var.instance_name}-allow-web-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = var.allowed_source_ranges
  target_tags   = [var.instance_name]
}

# ---------------------------------------------------------------------------
# Compute Instance (e2 series)
# ---------------------------------------------------------------------------

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type # e.g. e2-medium
  zone         = var.zone
  tags         = [var.instance_name]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.public.id

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    startup-script = file("${path.module}/startup.sh")
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    managed-by = "terraform"
    role       = "docker-nginx-host"
  }
}
