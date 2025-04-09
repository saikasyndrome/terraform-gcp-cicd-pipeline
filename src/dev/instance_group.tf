locals {
  instance_groups = [
    {
      name               = "nginx-${terraform.workspace}-instance-group"
      project            = local.project_id[terraform.workspace]
      base_instance_name = "nginx-${terraform.workspace}"
      target_size        = 1
      region             = local.region
      instance_template  = google_compute_instance_template.nginx_template["nginx-${terraform.workspace}-instance-template"].self_link
      health_check       = google_compute_health_check.nginx_dev_instance_group_health_check["nginx-${terraform.workspace}-instance-group-health-check"].self_link
      initial_delay_sec  = 300
      named_port_name    = "http"
      named_port_port    = 80
    }
  ]

  autoscalers = [
    {
      name            = "nginx-${terraform.workspace}-autoscaler"
      project         = local.project_id[terraform.workspace]
      target          = google_compute_region_instance_group_manager.nginx_dev_instance_group["nginx-${terraform.workspace}-instance-group"].self_link
      region          = local.region
      max_replicas    = 1
      min_replicas    = 0
      cooldown_period = 60
      cpu_target      = 0.6
    }
  ]

  health_checks_mg = [
    {
      name                = "nginx-${terraform.workspace}-instance-group-health-check"
      description         = "MIG用のヘルスチェック"
      project             = local.project_id[terraform.workspace]
      check_interval_sec  = 5
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      port                = 80
    }
  ]
}

resource "google_compute_region_instance_group_manager" "nginx_dev_instance_group" {
  for_each = { for x in local.instance_groups : x.name => x }

  project            = each.value.project
  name               = each.value.name
  base_instance_name = each.value.base_instance_name
  target_size        = each.value.target_size
  region             = each.value.region

  version {
    instance_template = each.value.instance_template
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.nginx_dev_instance_group_health_check["nginx-${terraform.workspace}-instance-group-health-check"].self_link
    initial_delay_sec = each.value.initial_delay_sec
  }

  named_port {
    name = each.value.named_port_name
    port = each.value.named_port_port
  }
  depends_on = [
    google_compute_instance_template.nginx_template,
    google_compute_health_check.nginx_dev_instance_group_health_check
  ]
}

resource "google_compute_region_autoscaler" "nginx_dev_autoscaler" {
  for_each = { for x in local.autoscalers : x.name => x }

  project = each.value.project
  name    = each.value.name
  target  = each.value.target
  region  = each.value.region

  autoscaling_policy {
    max_replicas    = each.value.max_replicas
    min_replicas    = each.value.min_replicas
    cooldown_period = each.value.cooldown_period

    cpu_utilization {
      target = each.value.cpu_target
    }
  }

  depends_on = [
    google_compute_region_instance_group_manager.nginx_dev_instance_group
  ]
}

resource "google_compute_health_check" "nginx_dev_instance_group_health_check" {
  for_each = { for x in local.health_checks_mg : x.name => x }

  project             = each.value.project
  name                = each.value.name
  check_interval_sec  = each.value.check_interval_sec
  timeout_sec         = each.value.timeout_sec
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold

  tcp_health_check {
    port = each.value.port
  }

  description = each.value.description
}
