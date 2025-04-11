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
