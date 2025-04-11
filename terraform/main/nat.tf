locals {
  regional_addresses_nat = [
    {
      name    = "cloud-nat-ip"
      project = local.project_id[terraform.workspace]
      region  = local.region
    }
  ]

  routers = [
    {
      name        = "router-${terraform.workspace}"
      project     = local.project_id[terraform.workspace]
      description = "service-vpc-${terraform.workspace}ネットワークのasia-northeast1リージョンでNATゲートウェイ接続を管理するために使用"
      network     = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      region      = local.region
      bgp = {
        asn            = 64514
        advertise_mode = "DEFAULT"
      }
    }
  ]

  nat_configs = [
    {
      name                               = "nat-${terraform.workspace}"
      project                            = local.project_id[terraform.workspace]
      region                             = local.region
      router                             = google_compute_router.cloud_router["router-${terraform.workspace}"].name
      nat_ip_allocate_option             = "MANUAL_ONLY"
      nat_ip_name                        = google_compute_address.cloud_nat["cloud-nat-ip"].self_link
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    }
  ]
}

resource "google_compute_address" "cloud_nat" {
  for_each = { for x in local.regional_addresses_nat : x.name => x }

  project = each.value.project
  name    = each.value.name
  region  = each.value.region
}

resource "google_compute_router" "cloud_router" {
  for_each = { for router in local.routers : router.name => router }

  name        = each.value.name
  project     = each.value.project
  description = each.value.description
  network     = each.value.network
  region      = each.value.region
  bgp {
    asn            = each.value.bgp.asn
    advertise_mode = each.value.bgp.advertise_mode
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = { for nat in local.nat_configs : nat.name => nat }

  name    = each.value.name
  project = each.value.project
  region  = each.value.region
  router  = each.value.router

  nat_ip_allocate_option = each.value.nat_ip_allocate_option
  nat_ips                = [each.value.nat_ip_name]

  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat

  depends_on = [
    google_compute_router.cloud_router,
    google_compute_address.cloud_nat,
    google_compute_network.vpc_network,
    google_compute_subnetwork.vpc_subnet
  ]
}
