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

resource "google_sql_database" "db" {
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
# Outputs
# ---------------------------------------------------------------------------

output "db_instance_name" {
  value = google_sql_database_instance.mysql.name
}

output "db_private_ip" {
  value       = google_sql_database_instance.mysql.private_ip_address
  description = "Private IP of the MySQL instance — accessible only from within the VPC"
}

output "db_connection_name" {
  value = google_sql_database_instance.mysql.connection_name
}