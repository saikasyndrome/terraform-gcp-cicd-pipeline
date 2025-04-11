locals {
  source_image = {
    #NEW
    prd = "projects//images/nginx-prd-image"
    #NEW
    dev = "projects//global/images/nginx-dev-image"
  }
}
locals {
  instance_templates = [
    {
      name         = "nginx-${terraform.workspace}-instance-template"
      project      = local.project_id[terraform.workspace]
      machine_type = "e2-small"
      region       = local.region
      description  = "nginxのディスクを元にしたインスタンステンプレート"
      tags         = ["nginx"]
      source_image = local.source_image[terraform.workspace]
      auto_delete  = true
      boot         = true
      type         = "pd-balanced"
      disk_size_gb = 10
      network      = google_compute_network.vpc_network["service-vpc-${terraform.workspace}"].self_link
      subnetwork   = google_compute_subnetwork.vpc_subnet["service-subnet-${terraform.workspace}"].self_link
      stack_type   = "IPV4_ONLY"
      metadata = {
        "enable-osconfig" = "true"
        "enable-oslogin"  = "true"
      }
      service_account_email       = google_service_account.nginx_dev["nginx-${terraform.workspace}"].email
      service_account_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    }
  ]
}

resource "google_compute_instance_template" "nginx_template" {
  for_each = { for x in local.instance_templates : x.name => x }

  project      = each.value.project
  name         = each.value.name
  machine_type = each.value.machine_type
  region       = each.value.region
  description  = each.value.description
  tags         = each.value.tags

  disk {
    source_image = each.value.source_image
    auto_delete  = each.value.auto_delete
    boot         = each.value.boot
    type         = each.value.type
    disk_size_gb = each.value.disk_size_gb
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
    stack_type = each.value.stack_type
  }

  metadata = each.value.metadata

  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }

  shielded_instance_config {
    enable_secure_boot          = each.value.enable_secure_boot
    enable_vtpm                 = each.value.enable_vtpm
    enable_integrity_monitoring = each.value.enable_integrity_monitoring
  }
  depends_on = [
    google_compute_network.vpc_network,
    google_compute_subnetwork.vpc_subnet,
    google_service_account.nginx_dev
  ]
}
