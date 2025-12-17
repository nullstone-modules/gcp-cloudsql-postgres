data "google_client_config" "this" {}
data "google_compute_zones" "available" {}
data "google_project" "this" {}
data "google_service_account" "this" {}

locals {
  project_id         = data.google_project.this.project_id
  project_number     = data.google_project.this.number
  region             = data.google_client_config.this.region
  executing_sa_email = data.google_service_account.this.email
}

resource "google_project_service" "secret_manager" {
  service                    = "secretmanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "sqladmin" {
  service                    = "sqladmin.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}
