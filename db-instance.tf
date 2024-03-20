resource "google_sql_database_instance" "this" {
  depends_on = [google_service_networking_connection.private_vpc_connection]

  name                = local.resource_name
  database_version    = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  region              = data.google_compute_subnetwork.private0.region
  deletion_protection = false

  settings {
    tier              = var.instance_class
    activation_policy = "ALWAYS"
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_size         = var.allocated_storage
    disk_autoresize   = "true"
    disk_type         = "PD_SSD"
    pricing_plan      = "PER_USE"
    user_labels       = local.labels

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      transaction_log_retention_days = var.backup_retention_count

      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = var.backup_retention_count
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = "stable"
    }

    ip_configuration {
      require_ssl     = var.enforce_ssl
      private_network = local.vpc_id
      ipv4_enabled    = var.enable_public_access
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }
}

locals {
  db_port = 5432
}