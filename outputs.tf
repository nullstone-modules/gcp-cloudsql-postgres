output "db_connection_name" {
  value       = google_sql_database_instance.this.connection_name
  description = "string ||| The connection name of the instance to be used in connection strings. For example, when connecting with Cloud SQL Proxy."
}

output "db_admin_secret_name" {
  value       = google_secret_manager_secret.admin.name
  description = "string ||| The name of the secret in Google Secrets Manager containing the password"
}
