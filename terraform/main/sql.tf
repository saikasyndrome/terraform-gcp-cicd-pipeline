locals {
  database_instances = [
    {
      name                   = "db-${terraform.workspace}"
      project                = local.project_id[terraform.workspace]
      database_version       = "MYSQL_8_0"
      region                 = local.region
      tier                   = "db-f1-micro"
      availability_type      = "ZONAL"
      disk_type              = "PD_HDD"
      disk_size              = 10
      disk_autoresize        = false
      backup_enabled         = false
      ipv4_enabled           = false
      private_network        = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      query_insights_enabled = false
      database_flags = {
        name  = "cloudsql_iam_authentication"
        value = "on"
      }
      deletion_protection = false
    }
  ]

  sql_users = [
    {
      name     = "root"
      project  = local.project_id[terraform.workspace]
      instance = google_sql_database_instance.database["db-${terraform.workspace}"].name
    }
  ]
}

resource "google_sql_database_instance" "database" {
  for_each = { for x in local.database_instances : x.name => x }

  project          = each.value.project
  name             = each.value.name
  database_version = each.value.database_version
  region           = each.value.region

  settings {
    tier              = each.value.tier
    availability_type = each.value.availability_type
    disk_type         = each.value.disk_type
    disk_size         = each.value.disk_size
    disk_autoresize   = each.value.disk_autoresize

    backup_configuration {
      enabled = each.value.backup_enabled
    }

    ip_configuration {
      ipv4_enabled    = each.value.ipv4_enabled
      private_network = each.value.private_network
    }

    insights_config {
      query_insights_enabled = each.value.query_insights_enabled
    }

    database_flags {
      name  = each.value.database_flags.name
      value = each.value.database_flags.value
    }
  }

  deletion_protection = each.value.deletion_protection

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "random_password" "root_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "root_user" {
  for_each = { for x in local.sql_users : x.name => x }

  project  = each.value.project
  name     = each.value.name
  instance = each.value.instance
  password = random_password.root_password.result
  depends_on = [
    google_sql_database_instance.database
  ]
}
