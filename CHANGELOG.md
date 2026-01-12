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
