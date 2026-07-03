terraform {
  backend "gcs" {
    bucket = "dbs-network-terraform-state"
    prefix = "prod"
  }
}