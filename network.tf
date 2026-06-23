data "ns_connection" "network" {
  name     = "network"
  contract = "network/gcp/vpc"
}

locals {
  vpc_id                    = data.ns_connection.network.outputs.vpc_id
  vpc_name                  = data.ns_connection.network.outputs.vpc_name
  vpc_access_connector      = data.ns_connection.network.outputs.vpc_access_connector
  private_subnet_self_links = data.ns_connection.network.outputs.private_subnet_self_links
  internal_domain_fqdn      = try(data.ns_connection.network.outputs.internal_domain_fqdn, "")
  internal_domain_zone_id   = try(data.ns_connection.network.outputs.internal_domain_zone_id, "")
}

// Warn (rather than fail) when PSC is enabled but the network connection does not provide an internal
// DNS zone. Without it, we cannot register a stable hostname for the PSC endpoint.
check "psc_internal_domain_available" {
  assert {
    condition     = !var.enable_psc || (local.internal_domain_fqdn != "" && local.internal_domain_zone_id != "")
    error_message = "enable_psc is set but the network connection is missing internal_domain_fqdn/internal_domain_zone_id. The PSC endpoint cannot be registered in internal DNS without them."
  }
}

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

data "google_compute_subnetwork" "private0" {
  self_link = local.private_subnet_self_links[0]
}
