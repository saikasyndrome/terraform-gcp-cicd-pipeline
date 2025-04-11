locals {
  #Create service account
  service_accounts = [
    {
      name        = "cloud-build"
      account_id  = "cloud-build"
      project     = local.project_id
      description = "Cloud buildで使用するサービスアカウント"
    }
  ]
  #Create IAM
  iam = [
    {
      name    = "logs_writer"
      project = local.project_id
      role    = "roles/logging.logWriter"
      member  = "serviceAccount:${google_service_account.cloudbuild_service_account["cloud-build"].email}"
    },
    {
      name    = "monitoring_metric_writer"
      project = local.project_id
      role    = "roles/monitoring.metricWriter"
      member  = "serviceAccount:${google_service_account.cloudbuild_service_account["cloud-build"].email}"
    },
    {
      name    = "cloud_sql_client"
      project = local.project_id
      role    = "roles/cloudsql.client"
      member  = "serviceAccount:${google_service_account.cloudbuild_service_account["cloud-build"].email}"
    },
    {
      name    = "secretAccessor"
      project = local.project_id
      role    = "roles/secretmanager.secretAccessor"
      member  = "serviceAccount:${google_service_account.cloudbuild_service_account["cloud-build"].email}"
    },
  ]
}

resource "google_service_account" "cloudbuild_service_account" {
  for_each = { for x in local.service_accounts : x.name => x }

  project      = each.value.project
  account_id   = each.value.account_id
  display_name = each.value.name
  description  = each.value.description
}

resource "google_project_iam_member" "role" {
  for_each = { for x in local.iam : x.name => x }

  project = each.value.project
  role    = each.value.role
  member  = each.value.member

  depends_on = [
    google_service_account.cloudbuild_service_account
  ]
}
