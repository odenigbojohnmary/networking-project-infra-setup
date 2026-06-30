terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "prod"
  }
}