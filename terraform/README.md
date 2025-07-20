# Estrutura Terraform Principal

Este diretório contém a configuração básica para provisionar recursos no Google Cloud usando Terraform.

## Recursos que serão criados (Com base no mesmo ciclo de vida)

- **Bucket para o Composer:**Armazenamento utilizado pelo serviço Cloud Composer para DAGs, logs e outros arquivos.
- **Infraestrutura do Composer:**Provisionamento do ambiente Cloud Composer, incluindo configurações de rede, permissões e dependências necessárias.
- **Bucket para o Cloud Function:**Armazenamento utilizado para guardar código fonte, artefatos ou arquivos temporários usados pelas Cloud Functions.
- **Bucket para o BigQuery:**Armazenamento utilizado para scripts DDL/DML do BigQuery.
