###########################
# BUCKETS
###########################

resource "google_storage_bucket" "tf_composer_bucket" {
  name                      = "tf-composer-${random_id.suffix.hex}"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

resource "google_storage_bucket" "tf_cloud_functions_bucket" {
  name                      = "tf-cloud-functions-${random_id.suffix.hex}"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

resource "google_storage_bucket" "tf_bigquery_scripts_bucket" {
  name                      = "tf-bigquery-scripts-${random_id.suffix.hex}"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy             = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

###########################
# REDE E SUBREDE
###########################

resource "google_compute_network" "composer_prod_network" {
  name                    = "composer-prod-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "composer_prod_subnetwork" {
  name          = "composer-prod-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.composer_prod_network.id
}

###########################
# PEERING COM SERVICE NETWORKING
###########################

resource "google_compute_global_address" "composer_private_ip_range" {
  name          = "composer-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.composer_prod_network.id
}

resource "google_service_networking_connection" "composer_vpc_connection" {
  network                 = google_compute_network.composer_prod_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.composer_private_ip_range.name]
}

###########################
# AMBIENTE CLOUD COMPOSER
###########################

resource "google_composer_environment" "composer_env" {
  name   = "composer-prod"
  region = var.region

  depends_on = [
    google_service_networking_connection.composer_vpc_connection,
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
        cpu        = 1
        memory_gb  = 3.75
        storage_gb = 5
        count      = 1
      }

      web_server {
        cpu        = 1
        memory_gb  = 3.75
        storage_gb = 5
      }

      worker {
        cpu        = 1
        memory_gb  = 3.75
        storage_gb = 5
        min_count  = 1
        max_count  = 3
      }

    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      network         = google_compute_network.composer_prod_network.id
      subnetwork      = google_compute_subnetwork.composer_prod_subnetwork.id
      service_account = var.cloud_composer_sa
    }
  }
}
