# === BUCKETS ===
output "composer_bucket_name" {
  description = "Nome do bucket do Cloud Composer."
  value       = google_storage_bucket.tf_composer_bucket.name
}

output "bigquery_scripts_bucket_name" {
  description = "Nome do bucket para scripts DDL/DML do BigQuery."
  value       = google_storage_bucket.tf_bigquery_scripts_bucket.name
}

output "bigquery_scripts_bucket_uri" {
  description = "URI GCS do bucket de scripts do BigQuery."
  value       = "gs://${google_storage_bucket.tf_bigquery_scripts_bucket.name}"
}

# === COMPOSER ===
output "composer_environment_name" {
  description = "Nome do ambiente Cloud Composer criado."
  value       = google_composer_environment.composer_env.name
}

output "composer_gcs_bucket_uri" {
  description = "URI do bucket GCS para DAGs e plugins do Composer."
  value       = google_composer_environment.composer_env.config[0].dag_gcs_prefix
}

output "composer_airflow_uri" {
  description = "URL da UI do Airflow para o ambiente Composer."
  value       = google_composer_environment.composer_env.config[0].airflow_uri
}

# === REDE ===
output "vpc_network_name" {
  description = "Nome da VPC usada pelo Composer."
  value       = google_compute_network.prod_network.name
}

output "subnetwork_name" {
  description = "Nome da subrede usada pelo Composer."
  value       = google_compute_subnetwork.prod_subnetwork.name
}

output "subnetwork_self_link" {
  description = "Self-link da subrede (útil para referenciar em outros recursos)."
  value       = google_compute_subnetwork.prod_subnetwork.self_link
}

output "private_ip_range" {
  description = "CIDR reservado para o Composer (VPC Peering)."
  value       = google_compute_global_address.private_ip_range.address
}
