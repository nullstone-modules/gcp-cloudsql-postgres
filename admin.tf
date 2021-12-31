resource "random_password" "this" {
  // Master password length constraints differ for each database engine. For more information, see the available settings when creating each DB instance.
  length  = 16
  special = true

  // The password for the master database user can include any printable ASCII character except /, ", @, or a space.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "admin" {
  secret_id = "${local.resource_name}/admin"
  labels    = local.tags

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "admin" {
  secret      = google_secret_manager_secret.admin.id
  secret_data = jsonencode(tomap({ "username" = google_sql_user.admin.name, "password" = google_sql_user.admin.password }))
}

resource "google_sql_user" "admin" {
  instance = google_sql_database_instance.this.name
  name     = "admin"
  password = random_password.this.result
}
