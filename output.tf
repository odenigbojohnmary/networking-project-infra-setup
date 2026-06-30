# ---------------------------------------------------------------------------
# Outputs vpc, subnetwork, and compute instance details
# ---------------------------------------------------------------------------

output "instance_name" {
  value = google_compute_instance.vm.name
}

output "instance_public_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "instance_self_link" {
  value = google_compute_instance.vm.self_link
}

# ---------------------------------------------------------------------------
# Outputs database instance details
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