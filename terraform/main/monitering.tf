locals {
  notification_channels = [
    {
      name    = "shin-alert"
      project = local.project_id[terraform.workspace]
      type    = "email"
      email   = "saikasyndrome@gmail.com"
    }
  ]

  alerts = [
    {
      name                  = "instance-cpu-warning-alert-${terraform.workspace}"
      project               = local.project_id[terraform.workspace]
      severity              = "WARNING"
      threshold             = 0.7
      duration              = "300s" # 5 minutes
      align_period          = "60s"
      aligner               = "ALIGN_MEAN"
      filter                = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      comparison            = "COMPARISON_GT"
      combiner              = "OR"
      display_name          = "New condition"
      notification_channels = [google_monitoring_notification_channel.shin_alert["shin-alert"].id]
    },
    {
      name                  = "instance-cpu-critical-alert-${terraform.workspace}"
      project               = local.project_id[terraform.workspace]
      severity              = "CRITICAL"
      threshold             = 0.8
      duration              = "300s" # 5 minutes
      align_period          = "60s"
      aligner               = "ALIGN_MEAN"
      filter                = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      comparison            = "COMPARISON_GT"
      combiner              = "OR"
      display_name          = "New condition"
      notification_channels = [google_monitoring_notification_channel.shin_alert["shin-alert"].id]
    },

    {
      name                  = "uptime-${terraform.workspace}"
      project               = local.project_id[terraform.workspace]
      severity              = ""
      duration              = "60s" # 1 minute
      align_period          = "60s"
      aligner               = "ALIGN_NONE"
      filter                = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\""
      comparison            = "COMPARISON_LT"
      threshold             = 1
      combiner              = "OR"
      display_name          = "Uptime failure"
      notification_channels = [google_monitoring_notification_channel.shin_alert["shin-alert"].id]
    }
  ]

  # Uptime Checks
  uptime_checks = [
    {
      name           = "uptime-${terraform.workspace}"
      project        = local.project_id[terraform.workspace]
      #NEW
      host           = "saikasyndrome.${terraform.workspace}..dev"
      period         = "60s" # 1 minute
      timeout        = "10s"
      path           = "/"
      port           = 443
      request_method = "GET"
      use_ssl        = true
    }
  ]
}

# Notification Channel
resource "google_monitoring_notification_channel" "shin_alert" {
  for_each = { for nc in local.notification_channels : nc.name => nc }

  project      = each.value.project
  display_name = each.value.name
  type         = each.value.type
  labels = {
    email_address = each.value.email
  }
}

# Alert Policy
resource "google_monitoring_alert_policy" "instance_alert" {
  for_each = { for alert in local.alerts : alert.name => alert }

  display_name = each.value.name
  project      = each.value.project
  combiner     = each.value.combiner
  conditions {
    display_name = each.value.display_name
    condition_threshold {
      filter          = each.value.filter
      duration        = each.value.duration
      comparison      = each.value.comparison
      threshold_value = each.value.threshold
      aggregations {
        alignment_period   = each.value.align_period
        per_series_aligner = each.value.aligner
      }
    }
  }
  notification_channels = each.value.notification_channels
  severity              = each.value.severity
  depends_on = [
    google_monitoring_notification_channel.shin_alert
  ]
}

# Uptime Check
resource "google_monitoring_uptime_check_config" "uptime_check" {
  for_each = { for check in local.uptime_checks : check.name => check }

  display_name = each.value.name
  project      = each.value.project
  period       = each.value.period
  timeout      = each.value.timeout

  http_check {
    request_method = each.value.request_method
    path           = each.value.path
    port           = each.value.port
    use_ssl        = each.value.use_ssl
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = each.value.project
      host       = each.value.host
    }
  }
  depends_on = [
    google_monitoring_notification_channel.shin_alert
  ]
}
