# Artifact Registry — Docker image storage for the application

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "app_images" {
  location      = var.region
  repository_id = "networking-app"
  format        = "DOCKER"
  description   = "Docker images for the StatusWatch (networking-project-application) service"

  depends_on = [google_project_service.artifactregistry]
}
