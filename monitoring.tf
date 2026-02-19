// If `var.resource_alerts.enabled is set to true, this will create alerts for resource usage on this CloudSQL instance.

resource "google_monitoring_notification_channel" "email" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Alerts Email"
  type         = "email"

  labels = {
    email_address = var.resource_alerts.email
  }
}

locals {
  instance_name = google_sql_database_instance.this.name
  database_id   = "${local.project_id}:${google_sql_database_instance.this.name}"
}

# CPU Utilization Alert
resource "google_monitoring_alert_policy" "cloudsql_cpu" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL CPU Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > ${var.resource_alerts.cpu}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.cpu / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} CPU utilization exceeded ${var.resource_alerts.cpu}%. Consider scaling up the instance or optimizing queries."
    mime_type = "text/markdown"
  }
}

# Memory Utilization Alert
resource "google_monitoring_alert_policy" "cloudsql_memory" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Memory Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization > ${var.resource_alerts.memory}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/memory/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.memory / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} memory utilization exceeded ${var.resource_alerts.memory}%. Consider scaling up memory or investigating memory-intensive queries."
    mime_type = "text/markdown"
  }
}

# Disk Read I/O Alert
resource "google_monitoring_alert_policy" "cloudsql_disk_read_io" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Disk Read I/O High"
  combiner     = "OR"

  conditions {
    display_name = "Disk read ops > ${var.resource_alerts.io_read}/s"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/read_ops_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.io_read

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} experiencing high disk read I/O. This may indicate missing indexes or inefficient queries."
    mime_type = "text/markdown"
  }
}

# Disk Write I/O Alert
resource "google_monitoring_alert_policy" "cloudsql_disk_write_io" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Disk Write I/O High"
  combiner     = "OR"

  conditions {
    display_name = "Disk write ops > ${var.resource_alerts.io_write}/s"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/write_ops_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.io_write

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} experiencing high disk write I/O. Review write-heavy operations and consider batching writes."
    mime_type = "text/markdown"
  }
}

# Free Storage Alert (disk quota remaining)
resource "google_monitoring_alert_policy" "cloudsql_storage" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Free Storage Low"
  combiner     = "OR"

  conditions {
    display_name = "Disk utilization > ${var.resource_alerts.disk_low}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.disk_low / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} disk utilization exceeded ${var.resource_alerts.disk_low}%. Increase disk size or clean up unused data. Note: disk_autoresize is enabled but has limits."
    mime_type = "text/markdown"
  }
}

# Critical Storage Alert (more urgent threshold)
resource "google_monitoring_alert_policy" "cloudsql_storage_critical" {
  count = var.resource_alerts.enabled ? 1 : 0

  project      = local.project_id
  display_name = "Cloud SQL Free Storage Critical"
  combiner     = "OR"

  conditions {
    display_name = "Disk utilization > ${var.resource_alerts.disk_critical}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_alerts.memory / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email[count.index].id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "CRITICAL: Cloud SQL instance ${local.instance_name} disk utilization exceeded ${var.resource_alerts.disk_critical}%. Immediate action required to prevent database outage."
    mime_type = "text/markdown"
  }
}
