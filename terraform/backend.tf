# terraform backend configuration for storing state in a GCS bucket.
terraform {
  backend "gcs" {
    bucket = "dbs-network-terraform-state"
    prefix = "prod"
  }
}