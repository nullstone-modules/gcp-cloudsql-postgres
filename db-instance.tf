resource "google_sql_database_instance" "this" {
  name                = local.resource_name
  database_version    = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  region              = data.google_compute_subnetwork.private0.region
  deletion_protection = false

  settings {
    edition           = var.edition
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

    dynamic "database_flags" {
      for_each = var.db_flags

      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = "stable"
    }

    ip_configuration {
      ssl_mode        = var.enforce_ssl ? "ENCRYPTED_ONLY" : "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      private_network = local.vpc_id
      ipv4_enabled    = var.enable_public_access
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }

    dynamic "password_validation_policy" {
      for_each = var.enforce_secure_passwords ? [true] : []

      content {
        enable_password_policy      = true
        min_length                  = 8
        complexity                  = "COMPLEXITY_DEFAULT"
        reuse_interval              = 5
        disallow_username_substring = true
        password_change_interval    = "0s"
      }
    }
  }

  depends_on = [google_project_service.sqladmin]
}

locals {
  db_port = 5432
}
