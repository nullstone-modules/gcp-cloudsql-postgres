# 0.5.1 (Aug 10, 2026)
* Adjusted admin password to be valid when a strict password policy is enabled.

# 0.5.0 (Jul 30, 2026)
* Upgraded `gcp-pg-db-admin` to 0.9.0, which adds publications, logical replication slots, read-only table privileges, and a `REPLICATION` role attribute. 
* Fixed the `db-admin` host when `var.enable_psc` is enabled. A PSC instance has no private IP of its own, so the admin connection URL was left with an empty host, breaking database/role/grant creation for connected apps.
  Admin traffic now dials the Private Service Connect endpoint reserved by this module.

# 0.4.1 (Jul 03, 2026)
* Switched to using `data.ns_workspace.gcp_labels` instead of `tags`.
* Upgraded TF providers.

# 0.4.0 (Jun 24, 2026)
* Added `var.point_in_time_recovery_enabled` to enable point-in-time recovery on the database instance.
* Added `var.deletion_protection_enabled` to protect the instance from deletion at both the Terraform and GCP API levels.

# 0.3.0 (Jun 23, 2026)
* Added `var.enable_psc` to support Private Service Connect in addition to Private Service Access.

# 0.2.12 (Feb 20, 2026)
* Configure resource alerts through external `notification` connection.
* Renamed `var.resource_alerts` to `var.resource_thresholds` and removed notification info.

# 0.2.11 (Feb 19, 2026)
* Fixed validation for `var.resource_alerts`.

# 0.2.10 (Feb 19, 2026)
* Added `var.resource_alerts` to monitor resource usage and notify via email if resource usage exceeds thresholds.

# 0.2.9 (Jan 20, 2026)
* Added `var.ip_whitelist` to allow explicit external access without making public.

# 0.2.8 (Jan 16, 2026)
* Added `postgres_ssl_mode` to indicate encryption requirements for connections.

# 0.2.7 (Jan 12, 2026)
* Upgraded module to support a disabled password policy gracefully.

# 0.2.6 (Jan 12, 2026)
* Fixed password policy configuration.

# 0.2.5 (Jan 12, 2026)
* Added `var.enforce_secure_passwords` to enforce secure password policies on the database instance.

# 0.2.4 (Dec 17, 2025)
* Fixed invoker impersonators var.

# 0.2.3 (Dec 17, 2025)
* Fixed executing service account reference.

# 0.2.2 (Dec 17, 2025)
* Allow ns service account to execute db-admin function.

# 0.2.1 (Dec 11, 2025)
* Added `var.edition` with a default to non-production, cheaper instances.

# 0.2.0 (Dec 11, 2025)
* Migrated from `terraform` to `tofu`.
* Using service account impersonation instead of service account keys for db admin invoker.

# 0.1.9 (Dec 04, 2025)
* Changed the default postgres version to 17.

# 0.1.8 (Jan 31, 2025)
* Added support for database flags configuration through vars.

# 0.1.7 (Dec 05, 2024)
* Fixed Terraform syntax.

# 0.1.6 (Dec 05, 2024)
* Enable secrets manager first.

# 0.1.5 (Jan 31, 2025)
* Added `var.db_flags` to configure postgres.

# 0.1.4 (Nov 27, 2024)
* Upgrade google provider.

# 0.1.3 (Mar 21, 2024)
* Moved single private service access to nullstone-modules/gcp-network module.

# 0.1.2 (Mar 20, 2024)
* Upgrade db-admin to latest.

# 0.1.1 (Mar 20, 2024)
* Enabled Google APIs to ensure successful launch.
* Updated postgres versions.

# 0.1.0 (Jun 12, 2023)
* Initial draft
