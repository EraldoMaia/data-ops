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
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.prod_network.id
  secondary_ip_range {
    range_name    = "prod-subnetwork-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
  private_ip_google_access = true
}

###########################
# AMBIENTE CLOUD COMPOSER
###########################

resource "google_composer_environment" "composer_env" {
  name   = "composer-prod"
  region = var.region

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
      cpu        = 0.5
      memory_gb  = 2
      storage_gb = 1
      count      = 1
    }
    web_server {
      cpu        = 1
      memory_gb  = 2
      storage_gb = 1
    }
    worker {
      cpu        = 0.5
      memory_gb  = 2
      storage_gb = 1
      min_count  = 1
      max_count  = 3
    }

    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      network         = google_compute_network.prod_network.id
      subnetwork      = google_compute_subnetwork.prod_subnetwork.id
      service_account = var.cloud_composer_sa
    }
  }
}
