locals {
  firewall_rules = [
    {
      name                    = "allow-healthcheck"
      project                 = local.project_id[terraform.workspace]
      description             = "ヘルスチェックプローバーからのトラフィックを許可"
      network                 = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      priority                = 1000
      direction               = "INGRESS"
      source_ranges           = ["130.211.0.0/22", "35.191.0.0/16"]
      allow_protocol          = "tcp"
      allow_ports             = ["80"]
      target_service_accounts = [google_service_account.nginx_dev["nginx-${terraform.workspace}"].email]
    },
    {
      name                    = "allow-ssh-from-iap"
      project                 = local.project_id[terraform.workspace]
      description             = "IAP経由でのSSHアクセスを許可"
      network                 = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      priority                = 1010
      direction               = "INGRESS"
      source_ranges           = ["35.235.240.0/20"]
      allow_protocol          = "tcp"
      allow_ports             = ["22"]
      target_service_accounts = [google_service_account.nginx_dev["nginx-${terraform.workspace}"].email]
    }
  ]
}

resource "google_compute_firewall" "firewall_rules" {
  for_each = { for x in local.firewall_rules : x.name => x }

  project     = each.value.project
  name        = each.key
  description = each.value.description
  network     = each.value.network
  priority    = each.value.priority
  direction   = each.value.direction

  source_ranges = each.value.source_ranges
  allow {
    protocol = each.value.allow_protocol
    ports    = each.value.allow_ports
  }

  target_service_accounts = each.value.target_service_accounts

  depends_on = [
    google_compute_network.vpc_network,
    google_service_account.nginx_dev
  ]
}
