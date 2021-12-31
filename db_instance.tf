resource "google_sql_database_instance" "this" {
  depends_on = [google_service_networking_connection.private_vpc_connection]

  name                = local.resource_name
  database_version    = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  deletion_protection = false
  region              = data.google_compute_subnetwork.private0.region

  settings {
    tier              = var.tier
    activation_policy = "ALWAYS"
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_autoresize   = "true"
    disk_type         = "PD_SSD"
    pricing_plan      = "PER_USE"
    user_labels       = local.labels

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = var.backup_retention_count
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true
      private_network = local.vpc_id
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }
}
