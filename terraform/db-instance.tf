# Database VM — self-managed MySQL, private subnet, no public IP

resource "google_compute_instance" "db_instance" {
  name         = var.db_instance_name
  machine_type = var.db_machine_type
  zone         = var.zone
  tags         = ["private", "db"]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.db_boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.private.id
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = "apt-get update -y"

  labels = {
    managed-by = "terraform"
    project    = "dbs-networking-assignment"
    role       = "database"
  }
}
