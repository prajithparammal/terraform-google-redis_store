terraform {
  required_version = "0.12.24" # see https://releases.hashicorp.com/terraform/
}

provider "google" {
  version = "3.13.0" # see https://github.com/terraform-providers/terraform-provider-google/releases
}

locals {
  memory_store_name         = format("redis-%s", var.name_suffix)
  memory_store_display_name = "Redis generated by Terraform"
}

data "google_client_config" "google_client" {}

resource "google_project_service" "redis_api" {
  service            = "redis.googleapis.com"
  disable_on_destroy = false
}

resource "google_redis_instance" "redis_store" {
  name               = local.memory_store_name
  memory_size_gb     = var.memory_size_gb
  display_name       = local.memory_store_display_name
  redis_version      = var.redis_version
  tier               = var.service_tier
  authorized_network = var.vpc_network
  region             = data.google_client_config.google_client.region
  reserved_ip_range  = var.ip_cidr_range
  depends_on         = [google_project_service.redis_api]
  timeouts {
    create = var.redis_timeout
    update = var.redis_timeout
    delete = var.redis_timeout
  }
}
