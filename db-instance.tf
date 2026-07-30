resource "google_sql_database_instance" "this" {
  name                = local.resource_name
  database_version    = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  region              = data.google_compute_subnetwork.private0.region
  deletion_protection = var.deletion_protection_enabled

  settings {
    edition                     = var.edition
    tier                        = var.instance_class
    activation_policy           = "ALWAYS"
    availability_type           = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_size                   = var.allocated_storage
    disk_autoresize             = "true"
    disk_type                   = "PD_SSD"
    pricing_plan                = "PER_USE"
    user_labels                 = local.labels
    deletion_protection_enabled = var.deletion_protection_enabled

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      transaction_log_retention_days = var.backup_retention_count
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled

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
      ssl_mode = var.enforce_ssl ? "ENCRYPTED_ONLY" : "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      // PSC is mutually exclusive with private services access (private_network) and public access (ipv4_enabled).
      private_network = var.enable_psc ? null : local.vpc_id
      ipv4_enabled    = var.enable_psc ? false : var.enable_public_access

      dynamic "authorized_networks" {
        for_each = var.ip_whitelist

        content {
          value = authorized_networks.value
        }
      }

      dynamic "psc_config" {
        for_each = var.enable_psc ? [true] : []

        content {
          psc_enabled               = true
          allowed_consumer_projects = [local.project_id]
        }
      }
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
  db_port           = 5432
  postgres_ssl_mode = var.enforce_ssl ? "require" : "prefer"

  // Hostname (no trailing dot) of the Private Service Connect endpoint, registered in the network's internal DNS zone.
  psc_dns_name = "${local.block_name}.${trimsuffix(local.internal_domain_fqdn, ".")}"

  // Endpoint strategy: with PSC, connect via the internal DNS name; otherwise via the private IP.
  db_endpoint_psa = "${google_sql_database_instance.this.private_ip_address}:${local.db_port}"
  db_endpoint_psc = "${local.psc_dns_name}:${local.db_port}"

  // The host the db-admin function dials. Under PSC the instance has no private IP of its own,
  // so admin traffic goes through the consumer endpoint this module reserves.
  db_admin_host = var.enable_psc ? google_compute_address.psc[0].address : google_sql_database_instance.this.private_ip_address
}

// Warn (rather than fail) when both public access and PSC are requested. They are mutually exclusive;
// PSC takes precedence and public access is forced off.
check "psc_public_access_exclusive" {
  assert {
    condition     = !(var.enable_public_access && var.enable_psc)
    error_message = "enable_public_access and enable_psc are mutually exclusive. PSC takes precedence, so public access will be disabled on this instance."
  }
}
