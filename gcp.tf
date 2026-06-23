data "google_client_config" "this" {}
data "google_compute_zones" "available" {}
data "google_project" "this" {}
data "google_client_openid_userinfo" "this" {}

locals {
  project_id         = data.google_project.this.project_id
  project_number     = data.google_project.this.number
  region             = data.google_client_config.this.region
  executing_sa_email = data.google_client_openid_userinfo.this.email
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

// Required for the Private Service Connect endpoint (forwarding rule + reserved IP).
resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

// Required to register the PSC endpoint in the network's internal DNS zone.
resource "google_project_service" "dns" {
  service                    = "dns.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}
