# tfvars
variable "project_id" {
  description = "GCP project ID"
}

variable "region" {
  description = "GCP region"
}

locals {
  project_id = var.project_id
  region     = var.region
}
