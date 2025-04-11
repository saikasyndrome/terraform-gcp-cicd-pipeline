# tfvars
variable "project_id" {
  description = "GCP project ID"
}

variable "region" {
  description = "GCP region"
}

variable "installation_id" {
  description = "git app installation_id"
}

locals {
  project_id = var.project_id
  region     = var.region
}

terraform {
  required_version = ">= 1.9.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.38.0"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}
