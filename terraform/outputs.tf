
# Outputs vpc, subnetwork

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public.id
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private.id
}


# Outputs compute instance details


output "instance_name" {
  value = google_compute_instance.db-project-instance.name
}

output "instance_public_ip" {
  value = google_compute_instance.db-project-instance.network_interface[0].access_config[0].nat_ip
}

output "instance_self_link" {
  value = google_compute_instance.db-project-instance.self_link
}

# Outputs database instance details

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