terraform {
  required_providers {
    ns = {
      source = "nullstone-io/ns"
    }
  }
}

resource "random_string" "resource_suffix" {
  length  = 5
  lower   = true
  upper   = false
  number  = false
  special = false
}

data "ns_workspace" "this" {}

data "ns_connection" "network" {
  name = "network"
  type = "network/gcp"
}

locals {
  resource_name = "${data.ns_workspace.this.block_ref}-${random_string.resource_suffix.result}"
  tags          = data.ns_workspace.this.tags
  labels        = { for key, value in local.tags : lower(key) => value }
  vpc_id        = data.ns_connection.network.outputs.vpc_id
  vpc_name      = data.ns_connection.network.outputs.vpc_name
}

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

data "google_compute_subnetwork" "private0" {
  self_link = data.ns_connection.network.outputs.private_subnet_self_links[0]
}
