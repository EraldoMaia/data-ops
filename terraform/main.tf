resource "google_storage_bucket" "tf-composer-bucket" {
  name                      = "tf-composer-bucket-bucket"
  location                  = var.region
  storage_class             = "STANDARD"
  public_access_prevention  = "enforced"
}