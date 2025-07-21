###########################
# BUCKETS
###########################

resource "google_storage_bucket" "tf_composer_bucket" {
  name                      = "tf-composer-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

resource "google_storage_bucket" "tf_cloud_functions_bucket" {
  name                      = "tf-cloud-functions-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

resource "google_storage_bucket" "tf_bigquery_scripts_bucket" {
  name                      = "tf-bigquery-scripts-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

###########################
# REDE E SUBREDE
###########################

resource "google_compute_network" "prod_network" {
  name                    = "prod-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "prod_subnetwork" {
  name          = "prod-subnetwork"
  ip_cidr_range = "10.158.0.0/20"
  region        = var.region
  network       = google_compute_network.prod_network.id
  private_ip_google_access = true
}

###########################
# PEERING COM SERVICE NETWORKING
###########################

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.prod_network.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.prod_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_compute_router" "nat_router" {
  name    = "prod-nat-router"
  network = google_compute_network.prod_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "prod-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

###########################
# AMBIENTE CLOUD COMPOSER
###########################

resource "google_composer_environment" "composer_env" {
  name   = "composer-prod"
  region = var.region

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_storage_bucket.tf_composer_bucket
  ]

  storage_config {
    bucket = google_storage_bucket.tf_composer_bucket.name
  }

  config {
    resilience_mode = var.resilience_mode

    software_config {
      image_version = var.composer_image_version
    }

    workloads_config {
     scheduler {
      cpu        = 2
      memory_gb  = 7.5
      storage_gb = 5
      count      = 2
    }
    triggerer {
      cpu        = 0.5
      memory_gb  = 0.5
      storage_gb = 5
      count      = 1
    }
    web_server {
      cpu        = 2
      memory_gb  = 7.5
      storage_gb = 5
    }
    worker {
      cpu        = 2
      memory_gb  = 7.5
      storage_gb = 5
      min_count  = 2
      max_count  = 6
    }

    }

    environment_size = "ENVIRONMENT_SIZE_MEDIUM"

    node_config {
      # network         = google_compute_network.prod_network.id
      # subnetwork      = google_compute_subnetwork.prod_subnetwork.id
      network         = "default"
      subnetwork      = "default"
      service_account = var.cloud_composer_sa
    }
  }
}
