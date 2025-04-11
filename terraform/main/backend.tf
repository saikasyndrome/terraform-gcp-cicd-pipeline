terraform {
  backend "gcs" {
    bucket = "" #NEW
    prefix = "terraform/state"
  }
}
