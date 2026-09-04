data "ns_connection" "notification" {
  name     = "notification"
  contract = "datastore/gcp/notification"
  optional = true
}

locals {
  notification_name = try(data.ns_connection.notification.outputs.notification_name, "")

  instance_name = google_sql_database_instance.this.name
  database_id   = "${local.project_id}:${google_sql_database_instance.this.name}"
}

# CPU Utilization Alert
resource "google_monitoring_alert_policy" "cloudsql_cpu" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL CPU Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > ${var.resource_thresholds.cpu}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.cpu / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} CPU utilization exceeded ${var.resource_thresholds.cpu}%. Consider scaling up the instance or optimizing queries."
    mime_type = "text/markdown"
  }
}

# Memory Utilization Alert
resource "google_monitoring_alert_policy" "cloudsql_memory" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL Memory Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization > ${var.resource_thresholds.memory}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/memory/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.memory / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} memory utilization exceeded ${var.resource_thresholds.memory}%. Consider scaling up memory or investigating memory-intensive queries."
    mime_type = "text/markdown"
  }
}

# Disk Read I/O Alert
resource "google_monitoring_alert_policy" "cloudsql_disk_read_io" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL Disk Read I/O High"
  combiner     = "OR"

  conditions {
    display_name = "Disk read ops > ${var.resource_thresholds.io_read}/s"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/read_ops_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.io_read

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

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
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL Disk Write I/O High"
  combiner     = "OR"

  conditions {
    display_name = "Disk write ops > ${var.resource_thresholds.io_write}/s"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/write_ops_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.io_write

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

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
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL Free Storage Low"
  combiner     = "OR"

  conditions {
    display_name = "Disk utilization > ${var.resource_thresholds.disk_low}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.disk_low / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Cloud SQL instance ${local.instance_name} disk utilization exceeded ${var.resource_thresholds.disk_low}%. Increase disk size or clean up unused data. Note: disk_autoresize is enabled but has limits."
    mime_type = "text/markdown"
  }
}

# Critical Storage Alert (more urgent threshold)
resource "google_monitoring_alert_policy" "cloudsql_storage_critical" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL Free Storage Critical"
  combiner     = "OR"

  conditions {
    display_name = "Disk utilization > ${var.resource_thresholds.disk_critical}%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${local.database_id}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.memory / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "CRITICAL: Cloud SQL instance ${local.instance_name} disk utilization exceeded ${var.resource_thresholds.disk_critical}%. Immediate action required to prevent database outage."
    mime_type = "text/markdown"
  }
}

# DB Admin Function Error Rate Alert
#
# The db-admin function is a 2nd-gen Cloud Function backed by a Cloud Run service of the same name,
# so its request metrics are reported under the `cloud_run_revision` resource.
locals {
  db_admin_request_count = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${module.db_admin.function_name}\" AND metric.type=\"run.googleapis.com/request_count\""
}

resource "google_monitoring_alert_policy" "db_admin_error_rate" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Cloud SQL DB Admin Error Rate High"
  combiner     = "OR"

  conditions {
    display_name = "5xx rate > ${var.admin_thresholds.error_rate}%"

    condition_threshold {
      filter                  = "${local.db_admin_request_count} AND metric.labels.response_code_class=\"5xx\""
      denominator_filter      = local.db_admin_request_count
      duration                = "60s"
      comparison              = "COMPARISON_GT"
      threshold_value         = var.admin_thresholds.error_rate / 100
      evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      denominator_aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "The db-admin function for Cloud SQL instance ${local.instance_name} is returning 5xx responses. Database, role, and grant changes for connected apps will fail until this is resolved. Function logs: resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${module.db_admin.function_name}\""
    mime_type = "text/markdown"
  }
}
