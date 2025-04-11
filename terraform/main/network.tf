locals {
  networks = [
    {
      name                    = "service-vpc-${terraform.workspace}"
      project                 = local.project_id[terraform.workspace]
      description             = "SRE課題サービス用VPC"
      auto_create_subnetworks = false
      mtu                     = 1460
    }
  ]

  subnetworks = [
    {
      name                     = "service-subnet-${terraform.workspace}"
      project                  = local.project_id[terraform.workspace]
      description              = "SRE課題サービス用サブネット"
      ip_cidr_range            = "172.16.0.0/16"
      region                   = local.region
      network                  = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      private_ip_google_access = true
    }
  ]

  global_addresses_network = [
    {
      name          = "peering-global-address"
      project       = local.project_id[terraform.workspace]
      purpose       = "VPC_PEERING"
      address_type  = "INTERNAL"
      prefix_length = 16
      network       = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
    }
  ]

  service_networking_connections = [
    {
      name                    = "service-vpc-connection-${terraform.workspace}"
      network                 = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      service                 = "servicenetworking.googleapis.com"
      reserved_peering_ranges = [google_compute_global_address.private_ip_address["peering-global-address"].name]
    }
  ]
}

resource "google_compute_network" "vpc_network" {
  for_each = { for x in local.networks : x.name => x }

  project                 = each.value.project
  name                    = each.value.name
  description             = each.value.description
  auto_create_subnetworks = each.value.auto_create_subnetworks
  mtu                     = each.value.mtu
}

resource "google_compute_subnetwork" "vpc_subnet" {
  for_each = { for x in local.subnetworks : x.name => x }

  project                  = each.value.project
  name                     = each.value.name
  description              = each.value.description
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = each.value.region
  network                  = each.value.network
  private_ip_google_access = each.value.private_ip_google_access
  depends_on = [
    google_compute_network.vpc_network
  ]
}

resource "google_compute_global_address" "private_ip_address" {
  for_each = { for x in local.global_addresses_network : x.name => x }

  project       = each.value.project
  name          = each.value.name
  purpose       = each.value.purpose
  address_type  = each.value.address_type
  prefix_length = each.value.prefix_length
  network       = each.value.network
}

resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = { for x in local.service_networking_connections : x.name => x }

  network                 = each.value.network
  service                 = each.value.service
  reserved_peering_ranges = each.value.reserved_peering_ranges
  depends_on = [
    google_compute_network.vpc_network,
    google_compute_global_address.private_ip_address
  ]
}
