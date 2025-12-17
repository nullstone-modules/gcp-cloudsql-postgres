module "db_admin" {
  source  = "api.nullstone.io/nullstone/gcp-pg-db-admin/gcp"
  version = "~> 0.8.0"

  name   = local.resource_name
  labels = local.labels

  host                      = google_sql_database_instance.this.private_ip_address
  port                      = local.db_port
  database                  = "postgres"
  username                  = local.admin_username
  password                  = local.admin_password
  vpc_access_connector_name = local.vpc_access_connector

  invoker_impersonators = [
    local.ns_agent_service_account_email,
    local.executing_sa_email,
  ]

  depends_on = [google_project_service.secret_manager]
}
