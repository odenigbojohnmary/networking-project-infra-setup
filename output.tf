# ---------------------------------------------------------------------------
# Outputs
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