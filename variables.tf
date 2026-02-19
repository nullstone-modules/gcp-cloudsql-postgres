variable "postgres_version" {
  type        = string
  default     = "17"
  description = <<EOF
Specify the postgres engine to utilize.
Supported versions are 13, 14, 15, 16, 17, and 18.
By default, configured with 17.
EOF
}

variable "edition" {
  type        = string
  default     = "ENTERPRISE"
  description = <<EOF
By default, this is set to 'ENTERPRISE' which suits non-production environments.
For production environments, it is recommended to set this to 'ENTERPRISE_PLUS'.
EOF

  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "edition must be either 'ENTERPRISE' or 'ENTERPRISE_PLUS'"
  }
}

variable "instance_class" {
  type        = string
  default     = "db-f1-micro"
  description = <<EOF
The machine type to use.
By default, configured with db-f1-micro.
Available options:
db-f1-micro
db-g1-small
db-n1-standard-1
db-n1-standard-2
db-n1-standard-4
db-n1-standard-8
db-n1-standard-16
db-n1-standard-32
db-n1-standard-64
db-n1-standard-96
db-n1-highmem-2
db-n1-highmem-4
db-n1-highmem-8
db-n1-highmem-16
db-n1-highmem-32
db-n1-highmem-64
db-n1-highmem-96
EOF
}

variable "allocated_storage" {
  type        = number
  default     = 10
  description = "Allocated storage in GB"
}

variable "backup_retention_count" {
  type        = number
  default     = 7
  description = "The number of backups that are retained"
}

variable "maintenance_window" {
  type = object({
    day : number
    hour : number
  })
  default = {
    day  = 7
    hour = 23
  }
  description = <<EOF
Configuration for maintenance window.
Day of week => 1-7 starts on Monday.
Hour of day => 0-23.
By default, configured for Sunday at 11:00 PM.
EOF
}

variable "high_availability" {
  type        = bool
  default     = false
  description = <<EOF
Enables high availability and failover support on the database instance.
By default, this is disabled. It is recommended to enable this in production environments.
In dev environments, it is best to turn off to save on costs.
EOF
}

variable "enforce_ssl" {
  type        = bool
  default     = false
  description = <<EOF
By default, the postgres cluster will have SSL enabled.
This toggle will require an SSL connection.
This is highly recommended if you have public access enabled.
EOF
}

variable "enforce_secure_passwords" {
  type        = bool
  default     = false
  description = <<EOF
This enables a secure password policy on the database instance.
Specifically, this requires a minimum password length of 8 characters, a complexity of DEFAULT, a reuse interval of 5 days, disallowing the username in the password, and a password change interval of 0 seconds.
By default, this is disabled.
EOF
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = <<EOF
By default, the postgres cluster is not accessible to the public.
If you want to access your database, we recommend using a bastion instead.
EOF
}

variable "db_flags" {
  type        = map(string)
  default     = {}
  description = <<EOF
This is a dictionary of database flags to configure the postgres instance.
For a list of flags, see https://cloud.google.com/sql/docs/postgres/flags#list-flags-postgres
EOF
}

variable "ip_whitelist" {
  type        = set(string)
  default     = []
  description = <<EOF
Specify a set of IP addresses that allowed to access this postgres instance without exposing public access.
EOF
}

variable "resource_alerts" {
  type = object({
    enabled       = bool
    email         = string
    cpu           = number
    memory        = number
    io_read       = number
    io_write      = number
    disk_low      = number
    disk_critical = number
  })
  default = {
    enabled       = false
    email         = ""
    cpu           = 80
    memory        = 85
    io_read       = 1000
    io_write      = 1000
    disk_low      = 85
    disk_critical = 95
  }

  description = <<EOF
Enables alerts on resource usage for the postgres instance.

Each alert is configured to trigger when the resource usage exceeds the specified threshold.
The thresholds are specified as percentages. (i.e. 80 => 80%)
However, io_read and io_write are specified in ops per second.
EOF

  validation {
    condition     = !var.resource_alerts.enabled || var.resource_alerts.email != ""
    error_message = "email must be specified if alerts are enabled"
  }
}
