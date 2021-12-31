variable "postgres_version" {
  type        = string
  default     = "13"
  description = <<EOF
Specify the postgres engine to utilize.
Supported versions are 9.6, 10, 11, 12, and 13.
By default, configured with 13.
EOF
}

variable "tier" {
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
  default     = true
  description = <<EOF
Enables high availability and failover support on the database instance.
By default, this is enabled to ensure reliability.
In dev environments, it is best to turn off to save on costs.
EOF
}
