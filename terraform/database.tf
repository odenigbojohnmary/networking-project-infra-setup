# ---------------------------------------------------------------------------
# Cloud SQL — MySQL (private IP only)
# ---------------------------------------------------------------------------

resource "google_sql_database_instance" "mysql" {
  name             = var.db_instance_name
  database_version = var.db_version
  region           = var.region

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_size         = var.db_disk_size_gb
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false                              # No public IP
      private_network = google_compute_network.vpc.id
    }

    backup_configuration {
      enabled            = true
      binary_log_enabled = true # Required for MySQL PITR
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3
      update_track = "stable"
    }
  }

  deletion_protection = var.db_deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "dbs-appdb" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql.name
  charset  = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql.name
  password = var.db_password
  host     = "%"
}
 
 
# ---------------------------------------------------------------------------
# Private Services Access (required for Cloud SQL private IP)
# ---------------------------------------------------------------------------
 
resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.vpc_name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}
 
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
 
  depends_on = [google_project_service.servicenetworking]
}
 
# ---------------------------------------------------------------------------
# Required APIs
# ---------------------------------------------------------------------------
 
resource "google_project_service" "servicenetworking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}
 
resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}