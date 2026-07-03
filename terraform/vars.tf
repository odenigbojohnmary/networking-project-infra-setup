# ---------------------------------------------------------------------------
# Project / Region
# ---------------------------------------------------------------------------
 
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
 
variable "region" {
  description = "GCP region. us-central1 is one of only three regions (with us-west1, us-east1) eligible for GCP's Always Free e2-micro instance, and is generally GCP's cheapest region overall."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
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
# Database — self-managed MySQL on a private Compute Engine VM
# ---------------------------------------------------------------------------
# Cloud SQL's private-IP feature requires either VPC Peering or Private
# Service Connect, both of which need GCP IAM permissions beyond plain
# Compute Engine access, and both add cost on top of the instance itself.
# A self-managed MySQL install on a private-subnet VM avoids both, reuses
# the Compute Engine permissions that already work for the app VM, and is
# cheaper. Ansible (not Terraform) installs and configures MySQL — see
# ansible/playbook.yml.

variable "db_instance_name" {
  description = "Name of the private database VM"
  type        = string
  default     = "dbs-mysql"
}

variable "db_machine_type" {
  description = "Machine type for the database VM"
  type        = string
  default     = "e2-small"
}

variable "db_boot_disk_size_gb" {
  description = "Boot disk size in GB for the database VM"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the MySQL database Ansible creates on the DB VM"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "MySQL application user Ansible creates on the DB VM"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Password for db_user — pass via TF_VAR_db_password / the DB_PASSWORD repository secret. Consumed by Ansible, not Terraform, but declared here so both tools read it from the same secret."
  type        = string
  sensitive   = true
}
