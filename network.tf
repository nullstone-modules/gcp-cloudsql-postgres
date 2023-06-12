data "ns_connection" "network" {
  name     = "network"
  contract = "network/gcp/vpc"
}

locals {
  vpc_id                    = data.ns_connection.network.outputs.vpc_id
  vpc_name                  = data.ns_connection.network.outputs.vpc_name
  vpc_access_connector      = data.ns_connection.network.outputs.vpc_access_connector
  private_subnet_self_links = data.ns_connection.network.outputs.private_subnet_self_links
}

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

data "google_compute_subnetwork" "private0" {
  self_link = local.private_subnet_self_links[0]
}
