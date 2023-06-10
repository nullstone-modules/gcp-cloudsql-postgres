data "ns_connection" "network" {
  name     = "network"
  type     = "network/gcp"
  contract = "network/gcp/vpc"
}

locals {
  vpc_id   = data.ns_connection.network.outputs.vpc_id
  vpc_name = data.ns_connection.network.outputs.vpc_name
}

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

data "google_compute_subnetwork" "private0" {
  self_link = data.ns_connection.network.outputs.private_subnet_self_links[0]
}
