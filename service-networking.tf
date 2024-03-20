resource "google_compute_global_address" "db_private" {
  name          = "${local.resource_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.vpc_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_private.name]
}
