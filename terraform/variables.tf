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

variable "cloud_build_sa" {
  type        = string
  default     = "cloud-build-sa@data-ops-466417.iam.gserviceaccount.com"
  description = "Conta de servico para os processos do cloud build."
}
