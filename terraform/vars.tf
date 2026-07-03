# ---------------------------------------------------------------------------
# Project / Region
# ---------------------------------------------------------------------------
 
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
 
variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}
 
variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-c"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
 
variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "dbs-vpc"
}
 
variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (VM)"
  type        = string
  default     = "10.0.1.0/24"
}
 
variable "private_subnet_cidr" {
  description = "CIDR for the private subnet (DB)"
  type        = string
  default     = "10.0.2.0/24"
}
 
variable "allowed_source_ranges" {
  description = "CIDR ranges allowed to reach SSH/HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "name" {
  description = "Name for the VPC"
  type        = string
  default     = "dbs-project"
}

# ---------------------------------------------------------------------------
# Compute Instance
# ---------------------------------------------------------------------------

variable "instance_name" {
  description = "Name for the compute instance"
  type        = string
  default     = "dbs-project-network-instance"
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}
 
variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 30
}
 
variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-balanced"
}

variable "ssh_user" {
  description = "Username used for SSH / Ansible access."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Contents of the SSH public key injected into the VM metadata (e.g. contents of id_rsa.pub). Passed as a string, not a file path, so it works both locally (via terraform.tfvars) and in GitHub Actions (via the TF_VAR_ssh_public_key environment variable, sourced from the SSH_PUBLIC_KEY repository secret)."
  type        = string
}

variable "app_port" {
  description = "Host port on which the containerised Flask application is published."
  type        = number
  default     = 5000
}
 
 # ---------------------------------------------------------------------------
# Cloud SQL — MySQL
# ---------------------------------------------------------------------------
 
variable "db_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "dbs-mysql"
}
 
variable "db_version" {
  description = "MySQL version"
  type        = string
  default     = "MYSQL_8_0"
}
 
variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}
 
variable "db_availability_type" {
  description = "ZONAL or REGIONAL (REGIONAL = high availability)"
  type        = string
  default     = "ZONAL"
}
 
variable "db_disk_size_gb" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 20
}
 
variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}
 
variable "db_user" {
  description = "Database user"
  type        = string
  default     = "appuser"
}
 
variable "db_password" {
  description = "Database password — pass via TF_VAR_db_password env var or secrets manager"
  type        = string
  sensitive   = true
}
 
variable "db_deletion_protection" {
  description = "Prevent accidental deletion of the DB instance"
  type        = bool
  default     = true
}
