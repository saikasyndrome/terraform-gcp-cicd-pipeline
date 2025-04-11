locals {
  #Create service account
  service_accounts = [
    {
      name        = "nginx-${terraform.workspace}"
      account_id  = "nginx-${terraform.workspace}"
      project     = local.project_id[terraform.workspace]
      description = "nginx VMで使用するサービスアカウント"
    }
  ]
  #Create IAM
  iam = [
    {
      name    = "logs_writer"
      project = local.project_id[terraform.workspace]
      role    = "roles/logging.logWriter"
      member  = "serviceAccount:${google_service_account.nginx_dev["nginx-${terraform.workspace}"].email}"
    },
    {
      name    = "monitoring_metric_writer"
      project = local.project_id[terraform.workspace]
      role    = "roles/monitoring.metricWriter"
      member  = "serviceAccount:${google_service_account.nginx_dev["nginx-${terraform.workspace}"].email}"
    },
    {
      name    = "cloud_sql_client"
      project = local.project_id[terraform.workspace]
      role    = "roles/cloudsql.client"
      member  = "serviceAccount:${google_service_account.nginx_dev["nginx-${terraform.workspace}"].email}"
    }
  ]
}

resource "google_service_account" "nginx_dev" {
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
    google_service_account.nginx_dev
  ]
}
