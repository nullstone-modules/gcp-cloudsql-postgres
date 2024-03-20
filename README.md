# CloudSQL Postgresql

This Nullstone module is used to create a GCP CloudSQL PostgreSQL instance.
Additionally, this module creates resources that are necessary to securely connect apps via Nullstone.

## How it is configured

The CloudSQL instance is configured with a private IP so that communication between your apps and the database happen over a private networking connection.
This enables lower latency and more secure communication.
This module follows the instructions by Google to configure with private networking:
- [Configure private IP](https://cloud.google.com/sql/docs/postgres/configure-private-ip)
- [Configure private services access](https://cloud.google.com/sql/docs/postgres/configure-private-services-access)
