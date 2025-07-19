# Estrutura Terraform Principal

Este diretório contém a configuração básica para provisionar recursos no Google Cloud usando Terraform.

## Recursos que serão criados

- **Bucket para o Composer:**Armazenamento utilizado pelo serviço Cloud Composer para DAGs, logs e outros arquivos.
- **Infraestrutura do Composer:**Provisionamento do ambiente Cloud Composer, incluindo configurações de rede, permissões e dependências necessárias.
- **Bucket para o Cloud Function:**Armazenamento utilizado para guardar código fonte, artefatos ou arquivos temporários usados pelas Cloud Functions.
- **Infraestrutura do Cloud Function:**
  Provisionamento das Cloud Functions, incluindo configuração de triggers, permissões e variáveis de ambiente.

## Como usar

1. Configure suas credenciais GCP.
2. Ajuste os valores em `variables.tf`.
3. Execute:
   ```
   terraform init
   terraform plan
   terraform apply
   ```
