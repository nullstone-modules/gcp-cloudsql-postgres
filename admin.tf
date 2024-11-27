resource "random_string" "admin_username" {
  length  = 5
  special = false
  numeric = true
  upper   = false
}

locals {
  admin_username = "ns_admin_${random_string.admin_username.result}"
  admin_password = random_password.this.result
}

// Second-gen CloudSQL instances destroy the `root` user upon creation
// This creates an admin user that is used for administration
resource "google_sql_user" "admin" {
  name     = local.admin_username
  password = local.admin_password
  instance = google_sql_database_instance.this.name
  type     = "BUILT_IN"
}

resource "random_password" "this" {
  // Master password length constraints differ for each database engine. For more information, see the available settings when creating each DB instance.
  length  = 16
  special = true

  // The password for the master database user can include any printable ASCII character except /, ", @, or a space.
  override_special = "!#%&*()-_=+[]{}<>:?"
}

locals {
  // Valid metadata name: [a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*
  app_secret_store_name = "${local.resource_name}-gsm-secrets"
}

resource "google_secret_manager_secret" "admin_creds" {
  // Valid secret_id: [[a-zA-Z_0-9]+]
  secret_id = "${local.resource_name}_admin"
  labels    = local.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager]
}

resource "google_secret_manager_secret_version" "admin_creds" {
  secret      = google_secret_manager_secret.admin_creds.id
  secret_data = jsonencode(tomap({ "username" = local.admin_username, "password" = local.admin_password }))
}
