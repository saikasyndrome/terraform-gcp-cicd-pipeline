locals {
  project_id = {
    #NEW
    prd = "NEW"
    #NEW
    dev = "NEW"
  }

  region = "asia-northeast1"
}

provider "google" {
  project = local.project_id[terraform.workspace]
  region  = local.region
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
