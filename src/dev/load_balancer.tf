locals {
  global_addresses_lb = [
    {
      name    = "nginx-lb-ip"
      project = local.project_id[terraform.workspace]
    }
  ]

  target_https_proxies = [
    {
      name             = "nginx-https-proxy"
      project          = local.project_id[terraform.workspace]
      url_map          = google_compute_url_map.default["nginx-lb"].self_link
      ssl_certificates = [google_compute_managed_ssl_certificate.nginx_dev_ssl["nginx-${terraform.workspace}-ssl"].self_link]
    }
  ]

  global_forwarding_rules = [
    {
      name                  = "nginx-https-forwarding-rule"
      project               = local.project_id[terraform.workspace]
      ip_address            = google_compute_global_address.default["nginx-lb-ip"].address
      target                = google_compute_target_https_proxy.default["nginx-https-proxy"].self_link
      ip_protocol           = "TCP"
      port_range            = "443"
      load_balancing_scheme = "EXTERNAL_MANAGED"
    }
  ]

  managed_ssl_certificates = [
    {
      name        = "nginx-${terraform.workspace}-ssl"
      project     = local.project_id[terraform.workspace]
      description = "shinjeongho.${terraform.workspace}.sandbox.cloud-ace.devのhttpsためのSSL証明書"
      domains     = ["shinjeongho.${terraform.workspace}.sandbox.cloud-ace.dev"]
    }
  ]

  backend_services = [
    {
      name                  = "nginx-backend-service"
      project               = local.project_id[terraform.workspace]
      description           = "MIG専用のloadbalancerのバックエンド、nginxのインスタンスグループで適用するロードバランサーのバックエンド"
      port_name             = "http"
      protocol              = "HTTP"
      load_balancing_scheme = "EXTERNAL_MANAGED"
      backend_group         = google_compute_region_instance_group_manager.nginx_dev_instance_group["nginx-${terraform.workspace}-instance-group"].instance_group
      health_check          = [google_compute_health_check.nginx_dev_load_balancer_health_check["nginx-${terraform.workspace}-health-check"].self_link]
      security_policy       = google_compute_security_policy.default["cloud-armor-backend-${terraform.workspace}"].self_link
    }
  ]

  url_maps = [
    {
      name            = "nginx-lb"
      project         = local.project_id[terraform.workspace]
      default_service = google_compute_backend_service.default["nginx-backend-service"].self_link
    }
  ]

  health_checks_lb = [
    {
      name                = "nginx-${terraform.workspace}-health-check"
      project             = local.project_id[terraform.workspace]
      check_interval_sec  = 5
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      port                = 80
      description         = "load balancerのバックエンド、ヘルスチェック"
    }
  ]
}

resource "google_compute_global_address" "default" {
  for_each = { for x in local.global_addresses_lb : x.name => x }

  project = each.value.project
  name    = each.value.name
}

resource "google_compute_target_https_proxy" "default" {
  for_each = { for x in local.target_https_proxies : x.name => x }

  project          = each.value.project
  name             = each.value.name
  url_map          = each.value.url_map
  ssl_certificates = each.value.ssl_certificates

  depends_on = [
    google_compute_managed_ssl_certificate.nginx_dev_ssl,
    google_compute_url_map.default
  ]
}
resource "google_compute_global_forwarding_rule" "https" {
  for_each = { for x in local.global_forwarding_rules : x.name => x }

  project               = each.value.project
  name                  = each.value.name
  ip_address            = each.value.ip_address
  target                = each.value.target
  ip_protocol           = each.value.ip_protocol
  port_range            = each.value.port_range
  load_balancing_scheme = each.value.load_balancing_scheme

  depends_on = [
    google_compute_global_address.default,
    google_compute_target_https_proxy.default
  ]
}

resource "google_compute_managed_ssl_certificate" "nginx_dev_ssl" {
  for_each = { for x in local.managed_ssl_certificates : x.name => x }

  project     = each.value.project
  name        = each.value.name
  description = each.value.description

  managed {
    domains = each.value.domains
  }

  depends_on = [
    google_compute_global_address.default
  ]
}

resource "google_compute_backend_service" "default" {
  for_each = { for x in local.backend_services : x.name => x }

  project               = each.value.project
  description           = each.value.description
  name                  = each.value.name
  port_name             = each.value.port_name
  protocol              = each.value.protocol
  load_balancing_scheme = each.value.load_balancing_scheme
  security_policy       = each.value.security_policy

  backend {
    group = each.value.backend_group
  }
  health_checks = each.value.health_check

  depends_on = [
    google_compute_instance_template.nginx_template,
    google_compute_region_instance_group_manager.nginx_dev_instance_group,
    google_compute_health_check.nginx_dev_load_balancer_health_check
  ]
}

resource "google_compute_url_map" "default" {
  for_each = { for x in local.url_maps : x.name => x }

  project         = each.value.project
  name            = each.value.name
  default_service = each.value.default_service

  depends_on = [
    google_compute_backend_service.default
  ]
}

resource "google_compute_health_check" "nginx_dev_load_balancer_health_check" {
  for_each = { for x in local.health_checks_lb : x.name => x }

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
