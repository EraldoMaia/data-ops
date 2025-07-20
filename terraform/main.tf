# Definição dos Buckets 
resource "google_storage_bucket" "tf_composer_bucket" {
  name                      = "tf-composer-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention  = "enforced"
}

resource "google_storage_bucket" "tf_cloud_functions_bucket" {
  name                      = "tf-cloud-functions-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention  = "enforced"
}

resource "google_storage_bucket" "tf_bigquery_scripts_bucket" {
  name                      = "tf-bigquery-scripts-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention  = "enforced"
}

# Definição do ambiente Cloud Function 
resource "google_cloudfunctions2_function" "python_script_function" {
  name        = "fnc-kaggle-sample-sales"
  location    = var.region

  build_config {
    runtime     = "python310"
    entry_point = "main" # Nome da função Python de entrada
    source {
      storage_source {
        bucket = google_storage_bucket.tf_cloud_functions_bucket.name
        object = "fnc-kaggle-sample-sales.zip" # Caminho do arquivo zip com o código Python
      }
    }
  }

  service_config {
        max_instance_count               = 3
        min_instance_count               = 1
        available_memory                 = "4Gi"
        timeout_seconds                  = 300
        max_instance_request_concurrency = 80
        available_cpu                    = "4"
        environment_variables = {
            SERVICE_CONFIG_TEST          = "config_test"
            SERVICE_CONFIG_DIFF_TEST     = var.cloud_function_sa
        }
        ingress_settings                 = "ALLOW_INTERNAL_ONLY"
        all_traffic_on_latest_revision   = true
        service_account_email            = var.cloud_function_sa
  }
}

# Definição do ambiente Cloud Composer
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

resource "google_composer_environment" "composer_env" {

  name            = "composer-prod"
  region          = var.region

  storage_config  {
    bucket = var.bucket
  }

  config {

    resilience_mode = var.resilience_mode

    software_config {
      image_version  = var.composer_image_version
    }

    workloads_config {
      scheduler {
        cpu        = 2
        memory_gb  = 7.5
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
    
    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      network         = google_compute_network.composer_prod_network.id
      subnetwork      = google_compute_subnetwork.composer_prod_subnetwork.id
      service_account = var.cloud_composer_sa
    }

  }

}