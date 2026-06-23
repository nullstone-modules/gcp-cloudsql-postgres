# CloudSQL Postgresql

This Nullstone module is used to create a GCP CloudSQL PostgreSQL instance.
Additionally, this module creates resources that are necessary to securely connect apps via Nullstone.

## How it is configured

By default, the CloudSQL instance is configured with a private IP so that communication between your apps and the database happens over a private networking connection.
This enables lower latency and more secure communication.
This module follows the instructions by Google to configure with private networking:
- [Configure private IP](https://cloud.google.com/sql/docs/postgres/configure-private-ip)
- [Configure private services access](https://cloud.google.com/sql/docs/postgres/configure-private-services-access)

## Connectivity: PSA vs PSC

There are two private ways to connect to this database. You pick one with the `enable_psc` variable. You do **not** need both — they are mutually exclusive.

**Recommendation: use Private Service Connect (PSC) by default.** It provides stronger network-level isolation than private services access, and — importantly — it's the connectivity model that other managed Google Cloud services expect when they need to reach your database. Set `enable_psc = true`.

### Private Service Connect (PSC) — recommended

PSC publishes the database as a "service" reachable through endpoints (a reserved private IP + forwarding rule that this module creates in your VPC) rather than by stitching the database's network into yours. This module also registers an internal DNS name for that endpoint, and `db_endpoint` becomes that hostname instead of a raw IP.

Why it's the better choice:

- **Stronger network-level isolation.** Unlike private services access, PSC does **not** use VPC peering. With PSA, Google peers a reserved IP range into your VPC, which merges network reachability between the two. With PSC, access is granted explicitly — one consumer endpoint at a time — and nothing else in the producer network becomes reachable. This is the main reason to prefer it.

- **It's how managed Google Cloud services connect to your database.** The most common reason to need PSC is integrating a managed service that has to reach your instance — for example **[Datastream](https://docs.cloud.google.com/datastream/docs/psc-interfaces)** replicating change data from this database into BigQuery, or **Database Migration Service** reading from it. These services run in Google-managed projects and connect over PSC (via PSC interfaces / network attachments). With PSA you'd be forced into workarounds (e.g. NAT VMs); with PSC the connection is native and private.

- **Works across project and VPC boundaries.** You can reach the database from the **same VPC, a different VPC, or a different project/organization** without re-architecting, and you only manage one IP per consumer VPC.

When `enable_psc = true`:
- Public access is **forced off** (`enable_public_access` is ignored — the two cannot be combined).
- Apps connect using the internal DNS hostname exposed by `db_endpoint`.

### Private Services Access (PSA) — the default, simpler option

This is what you get out of the box (`enable_psc = false`). Google reserves a range of private IPs inside your VPC (via VPC peering) and gives the database one of them. Any app in the same VPC can reach it over that private IP.

Choose PSA if:
- Your apps live in the **same VPC** as the database and you want the simplest setup with the fewest moving parts.
- You don't need the per-consumer isolation that PSC provides.

> Note: PSA remains the module default (`enable_psc = false`) for backward compatibility. New deployments that want the strongest isolation should opt into PSC.

### ⚠️ Switching an existing database between PSA and PSC

PSA and PSC are different connectivity models on the instance, so flipping `enable_psc` on an **existing** database forces the instance to be **replaced** — which destroys its data. Do not toggle this in place on a database you care about. Instead, take a backup (or export), create the instance with the new setting, and restore/migrate your data into it.
