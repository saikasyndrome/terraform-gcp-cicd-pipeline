terraform {
  backend "gcs" {
    # bucket = "$your-project-id"
    prefix = "terraform/state"
  }
}
