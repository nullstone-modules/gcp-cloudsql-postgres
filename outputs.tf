output "db_instance_name" {
  value       = google_sql_database_instance.this.name
  description = "string ||| Name of the PostgreSQL instance"
}

output "db_admin_secret_name" {
  value       = google_secret_manager_secret.admin_creds.secret_id
  description = "string ||| The name of the secret in Google Secrets Manager containing the admin credentials { username, password }"
}

output "db_endpoint" {
  value       = "${google_sql_database_instance.this.private_ip_address}:${local.db_port}"
  description = "string ||| The endpoint URL to access the PostgreSQL instance."
}

output "db_admin_function_name" {
  value       = module.db_admin.function_name
  description = "string ||| Google Cloud Function name for database admin utility"
}

output "db_admin_function_url" {
  value       = module.db_admin.function_url
  description = "string ||| Google Cloud Function url for database admin utility"
}

output "db_admin_invoker" {
  value       = module.db_admin.invoker
  description = "object({ email: string, impersonate: true }) ||| A GCP service account with explicit privilege invoke db admin cloud function."
  sensitive   = true
}
