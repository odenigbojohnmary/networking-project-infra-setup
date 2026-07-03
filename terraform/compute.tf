# Network (uses default VPC; override with var.network/var.subnetwork if needed)

resource "google_compute_firewall" "allow_http_https_ssh" {
  name    = "${var.instance_name}-allow-web-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", tostring(var.app_port)]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.instance_name}-project-instance"]
}

# Compute Instance (e2 series)

resource "google_compute_instance" "db-project-instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["${var.instance_name}-project-instance", "public"]

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
    # startup-script      = file("${path.module}/startup.sh")
    # startup-script-hash = local.startup_script_hash
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
 
  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = "apt-get update -y"


  labels = {
    managed-by          = "terraform"
    project             = "dbs-networking-assignment"
    # startup-script-hash = substr(local.startup_script_hash, 0, 8)
  }
 
  # lifecycle {
  #   replace_triggered_by = [terraform_data.startup_script_hash]
  # }
}
 
# Tracks startup script content — any change triggers instance replacement
# resource "terraform_data" "startup_script_hash" {
#   input = local.startup_script_hash
# }

