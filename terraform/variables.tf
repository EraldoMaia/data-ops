variable "region" {
  type        = string
  default     = "southamerica-east1"
  description = "Regiao onde os recursos serao criados."
}

variable "project_id" {
  type        = string
  default     = "data-ops-466417"
  description = "Id do projeto onde os recursos serao criados."
}

variable "cloud_composer_sa" {
  type        = string
  default     = "cloud-composer-sa@data-ops-466417.iam.gserviceaccount.com"
  description = "Conta de servico para os processos do cloud composer."
}

variable "composer_image_version" {
  description = "Versão da imagem do Cloud Composer."
  type        = string
  default     = "composer-2.13.3-airflow-2.10.5"
}

variable "resilience_mode" {
  description = "O modo de resiliência indica se a alta resiliência está habilitada para o ambiente ou não.."
  type        = string
  default     = "STANDARD_RESILIENCE"
}
