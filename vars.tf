variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "networking-dbs"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "name" {
  description = "Name for the VPC"
  type        = string
  default     = "dbs-project"
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.0.20.0/24"
}