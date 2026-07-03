
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

# Outputs database VM details

output "db_instance_name" {
  value = google_compute_instance.db_instance.name
}

output "db_instance_private_ip" {
  value       = google_compute_instance.db_instance.network_interface[0].network_ip
  description = "Private IP of the database VM — reachable only from within the VPC (e.g. via SSH ProxyJump through the app VM)."
}

# Outputs Artifact Registry details

output "artifact_registry_repository" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_images.repository_id}"
  description = "Full path prefix for pushing/pulling images, e.g. <this>/statuswatch:latest"
}